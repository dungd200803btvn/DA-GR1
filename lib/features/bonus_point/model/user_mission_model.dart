import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/enum/enum.dart';

class UserMissionModel {
  final String id;
  final String missionId;
  final MissionType type;
  final UserMissionStatus status;
  final int progress;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? expiredAt;

  bool get isActive => status == UserMissionStatus.inProgress && !isExpired;
  bool get isExpired => expiredAt != null && DateTime.now().isAfter(expiredAt!);

  UserMissionModel({
    required this.id,
    required this.missionId,
    required this.type,
    required this.status,
    required this.progress,
    this.startedAt,
    this.completedAt,
    this.expiredAt,
  });

  factory UserMissionModel.fromMap(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    return UserMissionModel(
      id: map['id'] as String ,
      missionId: map['missionId'] as String,
      type: MissionType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => MissionType.writeReview,
      ),
      status: _statusFromString(map['status'] as String),
      progress: map['progress'] ?? 0,
      startedAt: (map['startedAt'] != null)
          ? DateTime.parse(map['startedAt'])
          : null,
      completedAt: _parseTimestamp(map['completedAt']),
      expiredAt: (map['expiredAt'] != null)
          ? DateTime.parse(map['expiredAt'])
          : null,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'missionId': missionId,
      'type': type.name,
      'status': status.name, // enum to string
      'progress': progress,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiredAt': expiredAt?.toIso8601String(),
    };
  }

  static UserMissionStatus _statusFromString(String status) {
    switch (status) {
      case 'inProgress':
        return UserMissionStatus.inProgress;
      case 'completed':
        return UserMissionStatus.completed;
      case 'claimed':
        return UserMissionStatus.claimed;
      case 'expired':
        return UserMissionStatus.expired;
      default:
        return UserMissionStatus.inProgress; // fallback an toàn
    }
  }
}
