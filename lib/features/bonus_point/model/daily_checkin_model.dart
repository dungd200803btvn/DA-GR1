import 'package:cloud_firestore/cloud_firestore.dart';

class DailyCheckin{
  final String id;            // Firestore doc ID
  final String userId;
  final DateTime checkInDate; // Ngày check-in
  final int reward;           // Số điểm thưởng
  final int streakCount;      // Số ngày streak (nếu cần)

  DailyCheckin({
    required this.id,
    required this.userId,
    required this.checkInDate,
    required this.reward,
    required this.streakCount,
  });

  factory DailyCheckin.fromMap(DocumentSnapshot snapshot ){
    final map = snapshot.data() as Map<String, dynamic>;
    DateTime date;
    if (map['check_in_date'] is String) {
      date = DateTime.parse(map['check_in_date'] as String);
    } else if (map['check_in_date'] is Timestamp) {
      date = (map['check_in_date'] as Timestamp).toDate();
    } else {
      throw Exception("Invalid check_in_date type: ${map['check_in_date']}");
    }
    return DailyCheckin(
      id: map['id'] as String,
      userId: map['user_id'] ?? '',
      checkInDate: date,
      reward: map['reward'] ?? 0,
      streakCount: map['streak_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'user_id': userId,
      'check_in_date': checkInDate.toIso8601String(),
      'reward': reward,
      'streak_count': streakCount,
    };
  }
  
}