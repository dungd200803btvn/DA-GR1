import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimedVoucherModel {
  final String voucherId;
  final Timestamp claimedAt;
  final bool isUsed;
  final Timestamp? usedAt;

  ClaimedVoucherModel({
    required this.voucherId,
    required this.claimedAt,
    required this.isUsed,
    this.usedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'voucher_id': voucherId,
      'claimed_at': claimedAt,
      'is_used': isUsed,
      'used_at': usedAt,
    };
  }

  factory ClaimedVoucherModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ClaimedVoucherModel(
      voucherId: data['voucher_id'] as String,
      claimedAt: data['claimed_at'] as Timestamp,
      isUsed: data['is_used'] as bool,
      usedAt: data['used_at'] as Timestamp?,
    );
  }
}
