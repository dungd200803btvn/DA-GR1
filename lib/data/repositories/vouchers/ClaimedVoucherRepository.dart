import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/voucher/models/UserClaimedVoucher.dart';

class ClaimedVoucherRepository {
  static ClaimedVoucherRepository get instance => ClaimedVoucherRepository();
  final _db = FirebaseFirestore.instance;
  // Fetch all claimed vouchers for a user
  Future<List<ClaimedVoucherModel>> fetchAllClaimedVouchers(String userId) async {
    try {
      final result = await _db.collection('User')
          .doc(userId)
          .collection('claimed_vouchers')
          .get();
      return result.docs.map((doc) => ClaimedVoucherModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetching claimed vouchers: $e';
    }
  }

  Future<List<ClaimedVoucherModel>> fetchUserClaimedVouchers(String userId) async {
    try {
      final result = await _db.collection('User')
          .doc(userId)
          .collection('claimed_vouchers')
          .where('is_used',isEqualTo: false)
          .get();
      return result.docs.map((doc) => ClaimedVoucherModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetching claimed vouchers: $e';
    }
  }
// Fetch all used vouchers for a user
  Future<List<ClaimedVoucherModel>> fetchUserUsedVouchers(String userId) async {
    try {
      final result = await _db.collection('User').doc(userId).collection('claimed_vouchers')
          .where('is_used', isEqualTo: true)
          .get();
      return result.docs.map((doc) => ClaimedVoucherModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Error fetching claimed vouchers: $e';
    }
  }

  // Claim a voucher
  Future<void> claimVoucher(String userId, ClaimedVoucherModel claimedVoucher) async {
    try {
      await _db
          .collection('User')
          .doc(userId)
          .collection('claimed_vouchers')
          .add(claimedVoucher.toJson());
    } catch (e) {
      throw 'Error claiming voucher: $e';
    }
  }
  
  Future<bool> isClaimed(String userId, String voucherId) async {
    final querySnapshot = await _db
        .collection('User')
        .doc(userId)
        .collection('claimed_vouchers')
        .where('voucher_id', isEqualTo: voucherId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> isUsed(String userId, String voucherId) async {
    final querySnapshot = await _db
        .collection('User')
        .doc(userId)
        .collection('claimed_vouchers')
        .where('voucher_id', isEqualTo: voucherId)
        .get();

    // Nếu không có document nào thì chắc chắn chưa dùng
    if (querySnapshot.docs.isEmpty) return false;

    // Trả về true nếu tất cả đều có is_used == true
    return querySnapshot.docs.every((doc) => doc['is_used'] == true);
  }


  Future<void> applyVoucher(String userId, String voucherId) async {
    final querySnapshot = await _db
        .collection('User')
        .doc(userId)
        .collection('claimed_vouchers')
        .where('voucher_id', isEqualTo: voucherId)
        .where('is_used', isEqualTo: false)
        .limit(1) // chỉ lấy 1 bản ghi chưa dùng
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      await doc.reference.update({
        'is_used': true,
        'used_at': FieldValue.serverTimestamp(),
      });
    } else {
      // Optional: throw hoặc log nếu không tìm thấy voucher chưa dùng
      print('No unused voucher found to apply.');
    }
  }

}
