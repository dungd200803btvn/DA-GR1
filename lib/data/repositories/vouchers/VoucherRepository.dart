import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lcd_ecommerce_app/features/voucher/models/UserClaimedVoucher.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../features/voucher/models/VoucherModel.dart';

class VoucherRepository {
  static VoucherRepository get instance => VoucherRepository();
  final _db = FirebaseFirestore.instance;
  // Fetch all vouchers
  Future<List<VoucherModel>> fetchAllVouchers() async {
    try {
      final result = await _db.collection('voucher').get();
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
      final result = await _db.collection('voucher').where('end_date',isLessThanOrEqualTo: Timestamp.now())
          .get();
      return result.docs.map((doc) => VoucherModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetching vouchers: $e';
    }
  }

  Future<List<VoucherModel>> fetchUserClaimedVoucher(String userId) async {
    try {
      // Lấy danh sách voucherId mà user đã claim
      final claimedVouchersResult = await _db
          .collection('User')
          .doc(userId)
          .collection('claimed_vouchers')
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

  //insert voucher
  Future<void> insertVouchers() async {
    final CollectionReference voucherCollection =
    FirebaseFirestore.instance.collection('voucher');

    // Danh sách các loại voucher với thông tin mô tả
    final List<Map<String, dynamic>> voucherTemplates = [
      {
        'title': 'Fixed Discount',
        'description': 'Giảm 50.000 VNĐ cho đơn hàng.',
        'type': 'fixed_discount',
        'discount_value': 50000,
      },
      {
        'title': 'Percentage Discount',
        'description': 'Giảm 10% tổng giá trị đơn hàng (tối đa 100.000 VNĐ).',
        'type': 'percentage_discount',
        'discount_value': 10,
        'max_discount': 100000,
      },
      {
        'title': 'Free Shipping',
        'description': 'Miễn phí vận chuyển cho đơn hàng từ 200.000 VNĐ.',
        'type': 'free_shipping',
        'minimum_order': 200000,
      },
      {
        'title': 'Category-specific Voucher',
        'description': 'Giảm 20% cho các sản phẩm thuộc danh mục Thời Trang Nam.',
        'type': 'category_discount',
        'discount_value': 20,
        'applicable_categories': ['fashion_men'],
      },
      {
        'title': 'Product-specific Voucher',
        'description': 'Giảm 30.000 VNĐ khi mua điện thoại XYZ.',
        'type': 'product_discount',
        'discount_value': 30000,
        'applicable_products': ['product_xyz'],
      },
      {
        'title': 'User-specific Voucher',
        'description': 'Voucher chỉ dành cho khách hàng VIP.',
        'type': 'user_discount',
        'applicable_users': ['vip_user_1'],
      },
      {
        'title': 'First Purchase Voucher',
        'description': 'Giảm 100.000 VNĐ cho đơn hàng đầu tiên.',
        'type': 'first_purchase',
        'discount_value': 100000,
      },
      {
        'title': 'Campaign-specific Voucher',
        'description': 'Giảm 30% toàn bộ đơn hàng vào ngày Black Friday.',
        'type': 'campaign_discount',
        'discount_value': 30,
      },
      {
        'title': 'Points-based Voucher',
        'description': '100 điểm đổi được voucher giảm 50.000 VNĐ.',
        'type': 'points_based',
        'discount_value': 50000,
      },
      {
        'title': 'Limited Quantity Voucher',
        'description': 'Chỉ phát hành 100 voucher giảm 20%.',
        'type': 'limited_quantity',
        'discount_value': 20,
        'quantity': 100,
      },
      {
        'title': 'Minimum Order Value Voucher',
        'description': 'Giảm 50.000 VNĐ cho đơn hàng từ 500.000 VNĐ trở lên.',
        'type': 'minimum_order',
        'discount_value': 50000,
        'minimum_order': 500000,
      },
      {
        'title': 'Cashback Voucher',
        'description': 'Hoàn 10% giá trị đơn hàng vào ví điện tử.',
        'type': 'cashback',
        'discount_value': 10,
      },
      {
        'title': 'Flat Price Voucher',
        'description': 'Chỉ 199.000 VNĐ cho tất cả các sản phẩm thuộc danh mục Giày Dép.',
        'type': 'flat_price',
        'discount_value': 199000,
        'applicable_categories': ['shoes'],
      },
      {
        'title': 'Group Voucher',
        'description': 'Giảm 50% khi mời thêm 2 người bạn cùng mua sắm.',
        'type': 'group_voucher',
        'discount_value': 50,
      },
      {
        'title': 'Time-based Voucher',
        'description': 'Giảm 20% từ 8:00 - 10:00 sáng.',
        'type': 'time_based',
        'discount_value': 20,
        'start_date': Timestamp.fromDate(DateTime(2025, 1, 21, 8, 0)),
        'end_date': Timestamp.fromDate(DateTime(2026, 1, 21, 10, 0)),
      },
    ];

    // Tạo 5 document cho mỗi loại voucher
    for (var template in voucherTemplates) {
      for (int i = 0; i < 5; i++) {
        final newVoucher = {
          'id': FirebaseFirestore.instance.collection('voucher').doc().id,
          'title': template['title'],
          'description': template['description'],
          'type': template['type'],
          'discount_value': (template['discount_value'] ?? 0) + 2 * i,
          'max_discount': (template['max_discount'] ?? 0) + 100000 * i,
          'minimum_order': (template['minimum_order'] ?? 0) + 10000 * i,
          'applicable_users': template['applicable_users'] ?? [],
          'applicable_products': template['applicable_products'] ?? [],
          'applicable_categories': template['applicable_categories'] ?? [],
          'start_date': template['start_date'] ?? Timestamp.now(),
          'end_date': template['end_date'] ??
              Timestamp.fromDate(DateTime.now().add(const Duration(days: 365))),
          'quantity': (template['quantity'] ?? 1000) + 500 * i,
          'remaining_quantity': ((template['quantity'] ?? 1000) + 500 * i),
          'claimed_users': [],
          'is_active': true,
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
        };

        await voucherCollection.doc(newVoucher['id']).set(newVoucher);
      }
    }
  }

  Future<void> updatePointsBasedVouchers() async {
    try {
      // Truy vấn các voucher có type là 'points_based'
      final querySnapshot = await _db.collection('voucher').where('type', isEqualTo: 'points_based').get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        // Nếu voucher chưa có trường 'required_points'
        if (!data.containsKey('required_points')) {
          await doc.reference.update({'required_points': 100});
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
        await doc.reference.update({'discount_value': 999000});

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
