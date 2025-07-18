import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:app_my_app/features/voucher/models/UserClaimedVoucher.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../features/voucher/models/VoucherModel.dart';

class VoucherRepository {
  static VoucherRepository get instance => VoucherRepository();
  final _db = FirebaseFirestore.instance;
  // Fetch all vouchers
  Future<List<VoucherModel>> fetchAllVouchers() async {
    try {
      final result = await _db.collection('voucher').where('isRedeemableByPoint',isEqualTo:false).get();
      return result.docs.map((doc) => VoucherModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetching vouchers: $e';
    }
  }

  Future<List<VoucherModel>> fetchFreeShippingVouchers() async {
    try {
      final result = await _db.collection('voucher')
          .where('type',isEqualTo: 'free_shipping')
          .get();
      return result.docs.map((doc) => VoucherModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetching vouchers: $e';
    }
  }


  Future<List<VoucherModel>> fetchEntirePlatformVouchers() async {
    try {
      final result = await _db.collection('voucher').where('type',whereNotIn: [
        'free_shipping',
        'category_discount',
        'product_discount',
      ])
          .get();
      return result.docs.map((doc) => VoucherModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetching vouchers: $e';
    }
  }

  Future<List<VoucherModel>> fetchExpiredVouchers() async {
    try {
      final result = await _db.collection('voucher').where('endDate',isLessThanOrEqualTo: Timestamp.now())
          .get();
      return result.docs.map((doc) => VoucherModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetching vouchers: $e';
    }
  }

  Future<List<VoucherModel>> fetchRedeemableByPointVouchers() async {
    try {
      final result = await _db.collection('voucher').where('isRedeemableByPoint',isEqualTo:true)
          .get();
      return result.docs.map((doc) => VoucherModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetchRedeemableByPointVouchers(): $e';
    }
  }

  Future<List<VoucherModel>> fetchUserClaimedVoucher(String userId) async {
    try {
      // Lấy danh sách voucherId mà user đã claim
      final claimedVouchersResult = await _db
          .collection('User')
          .doc(userId)
          .collection('claimed_vouchers')
          .where('is_used',isEqualTo: false)
          .get();

      final claimedVoucherIds = claimedVouchersResult.docs
          .map((doc) => ClaimedVoucherModel.fromSnapshot(doc).voucherId)
          .toList();

      if (claimedVoucherIds.isEmpty) {
        return [];
      }

      // Chia danh sách claimedVoucherIds thành các nhóm tối đa 30 phần tử
      List<VoucherModel> vouchers = [];
      const int batchSize = 30;

      for (int i = 0; i < claimedVoucherIds.length; i += batchSize) {
        final subList = claimedVoucherIds.sublist(
            i,
            i + batchSize > claimedVoucherIds.length ? claimedVoucherIds.length : i + batchSize
        );

        final voucherResult = await _db
            .collection('voucher')
            .where('id', whereIn: subList)
            .get();

        vouchers.addAll(voucherResult.docs.map((doc) => VoucherModel.fromSnapshot(doc)));
      }

      return vouchers;
    } catch (e) {
      throw 'Error fetching vouchers: $e';
    }
  }

  Future<List<VoucherModel>> fetchUserClaimedVouchersDuplicated(String userId) async {
    try {
      final claimedSnapshot = await _db
          .collection('User')
          .doc(userId)
          .collection('claimed_vouchers')
          .where('is_used', isEqualTo: false)
          .get();

      if (claimedSnapshot.docs.isEmpty) return [];

      // Map đếm số lần mỗi voucherId được claim
      Map<String, int> claimCountMap = {};
      for (var doc in claimedSnapshot.docs) {
        final claimed = ClaimedVoucherModel.fromSnapshot(doc);
        claimCountMap.update(claimed.voucherId, (value) => value + 1, ifAbsent: () => 1);
      }

      // Truy vấn tất cả các voucher gốc
      final voucherIds = claimCountMap.keys.toList();
      Map<String, VoucherModel> voucherMap = {};

      const batchSize = 30;
      for (int i = 0; i < voucherIds.length; i += batchSize) {
        final subList = voucherIds.sublist(
          i,
          i + batchSize > voucherIds.length ? voucherIds.length : i + batchSize,
        );

        final voucherSnapshot = await _db
            .collection('voucher')
            .where('id', whereIn: subList)
            .get();

        for (var doc in voucherSnapshot.docs) {
          final voucher = VoucherModel.fromSnapshot(doc);
          voucherMap[voucher.id] = voucher;
        }
      }

      // Nhân bản từng voucher tương ứng với số lần được claim
      List<VoucherModel> result = [];
      for (var entry in claimCountMap.entries) {
        final voucher = voucherMap[entry.key];
        if (voucher != null) {
          result.addAll(List.generate(entry.value, (_) => voucher));
        }
      }

      return result;
    } catch (e) {
      throw 'Error fetching claimed vouchers with duplicates: $e';
    }
  }


  Future<List<VoucherModel>> fetchUsedVoucher(String userId) async {
    try {
      // Lấy danh sách voucherId mà user đã claim
      final claimedVouchersResult = await _db
          .collection('User')
          .doc(userId)
          .collection('claimed_vouchers').where('is_used',isEqualTo: true)
          .get();

      final claimedVoucherIds = claimedVouchersResult.docs
          .map((doc) => ClaimedVoucherModel.fromSnapshot(doc).voucherId)
          .toList();

      if (claimedVoucherIds.isEmpty) {
        return [];
      }

      // Chia danh sách claimedVoucherIds thành các nhóm tối đa 30 phần tử
      List<VoucherModel> vouchers = [];
      const int batchSize = 30;

      for (int i = 0; i < claimedVoucherIds.length; i += batchSize) {
        final subList = claimedVoucherIds.sublist(
            i,
            i + batchSize > claimedVoucherIds.length ? claimedVoucherIds.length : i + batchSize
        );

        final voucherResult = await _db
            .collection('voucher')
            .where('id', whereIn: subList)
            .get();

        vouchers.addAll(voucherResult.docs.map((doc) => VoucherModel.fromSnapshot(doc)));
      }

      return vouchers;
    } catch (e) {
      throw 'Error fetching vouchers: $e';
    }
  }


  Future<VoucherModel?> getVoucherById(String id) async{
    try {
      final result = await _db.collection('voucher').doc(id).get();
      if(result.exists){
        return VoucherModel.fromSnapshot(result);
      }
      else {
        throw 'Voucher with id $id not found';
      }
    } catch (e) {
      throw 'Error fetching voucher by id: $e';
    }
  }

  // Save a new voucher
  Future<void> saveVoucher(VoucherModel voucher) async {
    try {
      await _db.collection('voucher').doc(voucher.id).set(voucher.toJson());
    } catch (e) {
      throw 'Error saving voucher: $e';
    }
  }

  // Update voucher
  Future<void> updateVoucher(String id, Map<String, dynamic> updates) async {
    try {
      await _db.collection('voucher').doc(id).update(updates);
    } catch (e) {
      throw 'Error updating voucher: $e';
    }
  }

  // Delete voucher
  Future<void> deleteVoucher(String id) async {
    try {
      await _db.collection('voucher').doc(id).delete();
    } catch (e) {
      throw 'Error deleting voucher: $e';
    }
  }

  Future<void> updatePointsBasedVouchers() async {
    try {
      // Truy vấn các voucher có type là 'points_based'
      final querySnapshot = await _db.collection('voucher').where('type', isEqualTo: 'points_based').get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        // Nếu voucher chưa có trường 'required_points'
        if (!data.containsKey('requiredPoints')) {
          await doc.reference.update({'requiredPoints': 100});
          print('Updated voucher ${doc.id} with required_points = 100');
        }
      }
      print('All points_based vouchers updated successfully.');
    } catch (e) {
      print('Error updating vouchers: $e');
    }
  }

  Future<bool> isFirstPurchaseVoucher(VoucherModel voucher) async {
    final userId = UserController.instance.user.value.id;
    // Truy vấn collection Orders của user
    final result = await _db.collection('User').doc(userId).collection('Orders').get();
    // Nếu collection Orders rỗng (chưa có đơn hàng nào)
    if (result.docs.isEmpty) {
     return true;
    } else {
     return false;
    }
  }

  Future<void> updateCategoryAndFlatPriceVouchers() async {
    try {
      // Danh sách category cần cập nhật
      // Truy vấn các voucher có type là 'category_discount' hoặc 'flat_price'
      final querySnapshot = await _db
          .collection('voucher')
          .where('type', isEqualTo: 'flat_price')
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'discountValue': 999000});

      }

      if (kDebugMode) {
        print('All category_discount and flat_price vouchers updated successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating vouchers: $e');
      }
    }
  }
}
