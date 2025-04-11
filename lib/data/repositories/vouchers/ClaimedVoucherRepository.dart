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
        .where('is_used', isEqualTo: true)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> applyVoucher(String userId, String voucherId) async {
    final querySnapshot = await _db
        .collection('User')
        .doc(userId)
        .collection('claimed_vouchers')
        .where('voucher_id', isEqualTo: voucherId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({
        'is_used': true,
        'used_at': FieldValue.serverTimestamp(), });
    }
  }
}
