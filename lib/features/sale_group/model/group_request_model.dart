import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/enum/enum.dart';

class GroupRequestModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String groupId;
  final String message;
  final FriendRequestStatus status;
  final DateTime sentAt;
  final DateTime? respondedAt;

  GroupRequestModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.groupId,
    this.message = "",
    this.status = FriendRequestStatus.pending,
    required this.sentAt,
    this.respondedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'groupId':groupId,
      'message': message,
      'status': status.toString().split('.').last,
      'sentAt': sentAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  factory GroupRequestModel.fromMap(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    DateTime parseTimestamp(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is Timestamp) {
        return value.toDate();
      } else {
        throw Exception("Invalid timestamp type: $value");
      }
    }

    FriendRequestStatus parseStatus(String statusStr) {
      return FriendRequestStatus.values.firstWhere(
            (e) => e.toString().split('.').last == statusStr,
        orElse: () => FriendRequestStatus.pending,
      );
    }

    return GroupRequestModel(
      id: snapshot.id,
      fromUserId: map['fromUserId'] as String,
      toUserId: map['toUserId'] as String,
      groupId: map['groupId'] as String,
      message: map['message'] ?? "",
      status: parseStatus(map['status'] as String),
      sentAt: parseTimestamp(map['sentAt']),
      respondedAt: map['respondedAt'] != null
          ? parseTimestamp(map['respondedAt'])
          : null,
    );
  }
}
