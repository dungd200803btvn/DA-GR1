import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../features/bonus_point/model/mission_model.dart';
import '../../../features/bonus_point/model/user_mission_model.dart';
import '../../../utils/enum/enum.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../../utils/helper/cloud_helper_functions.dart';

class MissionRepository extends GetxController {
  static MissionRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Tạo nhiệm vụ mẫu (admin tạo)
  Future<void> createMission(MissionModel mission) async {
    await _db.collection('missions').doc(mission.id).set(mission.toMap());
  }
  Future<void> startUserMission(UserMissionModel userMission, String userId) async{
    DocumentReference documentReference =  await _db
        .collection('User')
        .doc(userId)
        .collection('user_missions')
        .add(userMission.toMap());
    await documentReference.update({
      'id':documentReference.id
    });
    }

  Future<List<MissionModel>> getAllMissions() async {
    final snapshot = await _db.collection('missions').get();
    return snapshot.docs.map((doc) => MissionModel.fromMap(doc)).toList();
  }
  Future<MissionModel> getMissionById(String id) async {
    try{
      final snapshot = await _db.collection('missions').doc(id).get();
      return MissionModel.fromMap(snapshot);
    }on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Error in  getMissionById() in MissionRepository';
    }
  }

  Future<List<UserMissionModel>> getUserMissions(String userId) async {
    final snapshot = await _db
        .collection('User')
        .doc(userId)
        .collection('user_missions')
        .get();
    return snapshot.docs.map((doc) => UserMissionModel.fromMap(doc)).toList();
  }

  Future<UserMissionModel?> getUserMissionById(String userId, String missionId) async {
    try {
      final snapshot = await _db
          .collection('User')
          .doc(userId)
          .collection('user_missions')
          .where('missionId', isEqualTo: missionId)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return UserMissionModel.fromMap(doc);
    } catch (e) {
      print('❌ Lỗi khi lấy user mission: $e');
      return null;
    }
  }


  Future<bool> hasUserStartedMission(String userId, String missionId) async{
    final querySnapshot = await _db
        .collection('User')
        .doc(userId)
        .collection('user_missions')
        .where('missionId',isEqualTo: missionId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Cập nhật tiến độ nhiệm vụ
  Future<void> updateUserMissionProgress({
    required String userId,
    required String missionId,
    required int progress,
    required bool completed,
  }) async {
    final querySnapshot = await _db
        .collection('User')
        .doc(userId)
        .collection('user_missions')
        .where('missionId', isEqualTo: missionId)
        .limit(1) // nếu bạn đảm bảo chỉ có 1 document
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      final data = {
        'progress': progress,
        'status': completed ? 'completed' : 'in_progress',
        'completedAt': completed ? FieldValue.serverTimestamp() : null,
      };
      await _db
          .collection('User')
          .doc(userId)
          .collection('user_missions')
          .doc(docId)
          .set(data, SetOptions(merge: true));
    } else {
      // Nếu không tìm thấy document, bạn có thể xử lý theo ý muốn, ví dụ:
      print('Mission with missionId $missionId not found for user $userId');
    }
  }

  Future<void> updateUserMissionStatus({
    required String userId,
    required String missionId,
    required String status,
  }) async {
      await  _db
          .collection('User')
          .doc(userId)
          .collection('user_missions')
          .doc(missionId)
          .set({
        'status':  status,
      }, SetOptions(merge: true));
    }

  Future<void> createMissionsBulk() async {
    print("Start createMissionsBulk() ");
    try{
      final String writeReviewUrl = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/write_review.jpg", "write_review");
      final String highValueOrderUrl =
      await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/high_value_order.jpg", "high_value_order");
      final String viewProductUrl = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/view_product.jpg", "view_product");
      final String quickOrderUrl = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/quick_order.jpg", "quick_order");
      final String viewShopUrl = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/view_shop.jpg", "view_shop");
      // dummy_missions.dart
      final List<MissionModel> dummyMissions = [
        MissionModel(
            id: '',
            title: 'Viết 1 đánh giá sản phẩm',
            description: 'Viết review cho 1 sản phẩm bạn đã mua',
            reward: 50,
            type: MissionType.writeReview,
            goal: 1,
            durationType: MissionDurationType.none,
            imgUrl: writeReviewUrl),
        MissionModel(
            id: '',
            title: 'Viết 10 đánh giá trong 7 ngày',
            description: 'Viết 3 review trong vòng 1 tuần',
            reward: 1000,
            type: MissionType.writeReview,
            goal: 10,
            durationType: MissionDurationType.weekly,
            imgUrl: writeReviewUrl),
        MissionModel(
            id: '',
            title: 'Viết 5 đánh giá trong 24 giờ',
            description: 'Viết review cho 5 sản phẩm trong 1 ngày',
            reward: 250,
            type: MissionType.writeReview,
            goal: 5,
            durationType: MissionDurationType.daily,
            imgUrl: writeReviewUrl),
        MissionModel(
            id: '',
            title: 'Viết 10 đánh giá trong 24 giờ',
            description: 'Viết review cho 5 sản phẩm trong 1 ngày',
            reward: 800,
            type: MissionType.writeReview,
            goal: 10,
            durationType: MissionDurationType.daily,
            imgUrl: writeReviewUrl),

        // Nhóm 2: Đơn hàng giá trị cao
        MissionModel(
            id: '',
            title: 'Đơn hàng trên 500k',
            description: 'Thực hiện đơn hàng có giá trị trên 500,000đ',
            reward: 400,
            type: MissionType.highValueOrder,
            goal: 1,
            threshold: 500000,
            imgUrl: highValueOrderUrl),
        MissionModel(
            id: '',
            title: 'Đơn hàng trong tuần',
            description: 'Hoàn tất 5 đơn hàng trên 1 triệu đồng',
            reward: 2000,
            type: MissionType.highValueOrder,
            goal: 5,
            threshold: 1000000,
            durationType: MissionDurationType.weekly,
            imgUrl: highValueOrderUrl),
        MissionModel(
            id: '',
            title: 'Đơn hàng trên 5 triệu trong tuần',
            description: 'Hoàn tất 2 đơn hàng từ 5,000,000đ trong 7 ngày',
            reward: 8000,
            type: MissionType.highValueOrder,
            goal: 2,
            durationType: MissionDurationType.weekly,
            threshold: 5000000,
            imgUrl: highValueOrderUrl),
        MissionModel(
            id: '',
            title: '2 đơn hàng trên 2 triệu trong ngày',
            description: 'Hoàn tất 2 đơn hàng từ 2,000,000đ trong 24h',
            reward: 2000,
            type: MissionType.highValueOrder,
            goal: 2,
            durationType: MissionDurationType.daily,
            threshold: 2000000,
            imgUrl: highValueOrderUrl),

        // Nhóm 3: Xem sản phẩm
        MissionModel(
            id: '',
            title: 'Xem 5 sản phẩm chi tiết',
            description: 'Xem chi tiết 5 sản phẩm bất kỳ',
            reward: 400,
            type: MissionType.viewProduct,
            goal: 5,
            durationType: MissionDurationType.none,
            imgUrl: viewProductUrl),
        MissionModel(
            id: '',
            title: 'Xem sản phẩm trong 1 ngày',
            description: 'Xem chi tiết 10 sản phẩm trong 24h',
            reward: 800,
            type: MissionType.viewProduct,
            goal: 10,
            durationType: MissionDurationType.daily,
            imgUrl: viewProductUrl),
        MissionModel(
            id: '',
            title: 'Xem 15 sản phẩm trong tuần',
            description: 'Xem 15 sản phẩm bất kỳ trong 7 ngày',
            reward: 1000,
            type: MissionType.viewProduct,
            goal: 15,
            durationType: MissionDurationType.weekly,
            imgUrl: viewProductUrl),
        MissionModel(
            id: '',
            title: 'Xem 20 sản phẩm trong tuần',
            description: 'Xem chi tiết 20 sản phẩm trong 7 ngày',
            reward: 2500,
            type: MissionType.viewProduct,
            goal: 20,
            durationType: MissionDurationType.weekly,
            imgUrl: viewProductUrl),

        // Nhóm 4: Đơn hàng trong 24h
        MissionModel(
            id: '',
            title: '1 đơn hàng trong ngày',
            description: 'Thực hiện 1 đơn hàng trong vòng 24 giờ',
            reward: 600,
            type: MissionType.quickOrder,
            goal: 1,
            durationType: MissionDurationType.daily,
            imgUrl: quickOrderUrl),
        MissionModel(
            id: '',
            title: '3 đơn hàng trong ngày',
            description: 'Thực hiện 3 đơn hàng trong vòng 24 giờ',
            reward: 1500,
            type: MissionType.quickOrder,
            goal: 3,
            durationType: MissionDurationType.daily,
            imgUrl: quickOrderUrl),
        MissionModel(
            id: '',
            title: '5 đơn hàng trong tuần',
            description: 'Hoàn thành 5 đơn hàng trong 7 ngày',
            reward: 2000,
            type: MissionType.quickOrder,
            goal: 5,
            durationType: MissionDurationType.weekly,
            imgUrl: quickOrderUrl),
        MissionModel(
            id: '',
            title: '10 đơn hàng không giới hạn thời gian',
            description: 'Thực hiện tổng cộng 10 đơn hàng bất kỳ',
            reward: 3000,
            type: MissionType.quickOrder,
            goal: 10,
            durationType: MissionDurationType.none,
            imgUrl: quickOrderUrl),

        // Nhóm 5: Xem shop / brand
        MissionModel(
            id: '',
            title: 'Xem 3 shop khác nhau',
            description: 'Xem chi tiết 3 shop khác nhau',
            reward: 200,
            type: MissionType.viewShop,
            goal: 3,
            durationType: MissionDurationType.none,
            imgUrl: viewShopUrl),
        MissionModel(
            id: '',
            title: 'Xem 5 shop trong 1 ngày',
            description: 'Xem chi tiết 5 shop khác nhau trong 24h',
            reward: 900,
            type: MissionType.viewShop,
            goal: 5,
            durationType: MissionDurationType.daily,
            imgUrl: viewShopUrl),
        MissionModel(
            id: '',
            title: 'Xem 3 thương hiệu khác nhau',
            description: 'Xem 3 thương hiệu khác nhau bất kỳ',
            reward: 250,
            type: MissionType.viewBrand,
            goal: 3,
            durationType: MissionDurationType.none,
            imgUrl: viewShopUrl),
        MissionModel(
            id: '',
            title: 'Xem 20 thương hiệu trong tuần',
            description: 'Xem 20 thương hiệu khác nhau trong vòng 7 ngày',
            reward: 1800,
            type: MissionType.viewBrand,
            goal: 20,
            durationType: MissionDurationType.weekly,
            imgUrl: viewShopUrl),
      ];

      for (final mission in dummyMissions) {
        final docRef = await _db.collection('missions').add(mission.toMap());
        await _db.collection('missions').doc(docRef.id).update({'id': docRef.id});
      }
    }catch(e){
      print('Error in create mission:$e');
    }finally{
      print('Done create mission');
    }

  }
}
