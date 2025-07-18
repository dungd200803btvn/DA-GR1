import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/enum/enum.dart';

class FriendModel {
  final String id;
  final String friendId;
  final String friendName;
  final DateTime acceptedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FriendStatus status;

  FriendModel({
    required this.id,
    required this.friendId,
    required this.friendName,
    required this.acceptedAt,
    required this.createdAt,
    required this.updatedAt,
    this.status = FriendStatus.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'friendId': friendId,
      'friendName': friendName,
      'acceptedAt': acceptedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  factory FriendModel.fromMap(DocumentSnapshot snapshot) {
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

    FriendStatus parseStatus(String statusStr) {
      return FriendStatus.values.firstWhere(
            (e) => e.toString().split('.').last == statusStr,
        orElse: () => FriendStatus.active,
      );
    }

    return FriendModel(
      id: map['id'] as String,
      friendId: map['friendId'] as String,
      friendName: map['friendName'] as String,
      acceptedAt: parseTimestamp(map['acceptedAt']),
      createdAt: parseTimestamp(map['createdAt']),
      updatedAt: parseTimestamp(map['updatedAt']),
      status: parseStatus(map['status'] as String),
    );
  }
}

