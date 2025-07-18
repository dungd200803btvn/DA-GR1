import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../features/sale_group/model/sale_group_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../../utils/singleton/user_singleton.dart';
import '../authentication/authentication_repository.dart';

class SaleGroupRepository {
  static SaleGroupRepository get instance => SaleGroupRepository();
  final _db = FirebaseFirestore.instance;

  // Tạo nhóm săn sale
  Future<void> createSaleGroup(SaleGroupModel group) async {
    DocumentReference documentReference = await _db
        .collection('sale_groups')
        .add(group.toMap());
    await documentReference.update({
      'id': documentReference.id
    });
  }

  Future<void> deleteSaleGroup(SaleGroupModel group) async {
    try {
      await _db.collection('sale_groups').doc(group.id).delete();
      print('Group ${group.id} deleted successfully.');
    } catch (e) {
      print('Error deleting group: $e');
      rethrow;
    }
  }

  // Lấy thông tin nhóm theo id
  Future<SaleGroupModel> getSaleGroupById(String id) async {
    try {
      final snapshot = await _db.collection('sale_groups').doc(id).get();
      return SaleGroupModel.fromMap(snapshot);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Error in  getSaleGroupById() in SaleGroupRepository';
    }
  }

  // Lấy danh sách các nhóm được tạo bởi một user cụ thể
  Future<List<SaleGroupModel>> getSaleGroupsByCreator() async {
    try {
      final String userId = AuthenticationRepository.instance.authUser!.uid;

      // 1. Lấy các nhóm mà user là creator
      final creatorSnapshot = await _db
          .collection('sale_groups')
          .where('creatorId', isEqualTo: userId)
          .get();
      // 2. Lấy các nhóm mà user là participant
      final participantSnapshot = await _db
          .collection('sale_groups')
          .where('participants', arrayContains: userId)
          .get();
      // 3. Gộp tất cả documents lại
      final allDocs = [...creatorSnapshot.docs, ...participantSnapshot.docs];
      // 4. Dùng map để loại bỏ các nhóm bị trùng (theo `id`)
      final uniqueGroupsMap = <String, SaleGroupModel>{};
      for (var doc in allDocs) {
        final group = SaleGroupModel.fromMap(doc);
        uniqueGroupsMap[group.id] = group; // key = id, sẽ ghi đè nếu trùng
      }
      // 5. Trả về danh sách nhóm duy nhất
      return uniqueGroupsMap.values.toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'ERROR IN getSaleGroupsByCreator(): $e';
    }
  }

  Future<void> updateGroupStatus(String groupId, String newStatus) async {
    try {
      await _db
          .collection('sale_groups')
          .doc(groupId)
          .update({'status': newStatus});
    } catch (e) {
      debugPrint("❌ Failed to update group status: $e");
    }
  }

  Future<bool> addUserToGroup(String groupId, String userId) async {
    final groupRef = _db.collection('sale_groups').doc(groupId);
    final groupSnap = await groupRef.get();
    if (groupSnap.exists) {
      final groupData = groupSnap.data()!;
      print("Thong tin group name: ${groupData['name']}");
      print("Thong tin group participants: ${groupData['participants']}");
      // Lấy currentParticipants và targetParticipants
      int currentParticipants = groupData['currentParticipants'] is int
          ? groupData['currentParticipants'] as int
          : 0;
      final int targetParticipants = groupData['targetParticipants'] is int
          ? groupData['targetParticipants'] as int
          : 0;
      // Tăng currentParticipants thêm 1
      final int updatedParticipantsCount = currentParticipants + 1;
      // Nếu số thành viên đạt targetParticipants và thời hạn của group chưa hết
      bool markCompleted = false;
      if (updatedParticipantsCount >= targetParticipants) {
        markCompleted = true;
      }
      // Chuẩn bị dữ liệu cập nhật:
      Map<String, dynamic> updateData = {
        'participants': FieldValue.arrayUnion([userId]),
        'currentParticipants': updatedParticipantsCount,
      };
      if (markCompleted) {
        updateData['status'] = 'completed';
        await groupRef.update(updateData);
        return true;
      }else{
        await groupRef.update(updateData);
        return false;
      }
    }
    return false;
  }
}
