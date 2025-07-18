import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../features/bonus_point/model/daily_checkin_model.dart';

class DailyCheckInRepository {
  static DailyCheckInRepository get instance => DailyCheckInRepository();
  final _db = FirebaseFirestore.instance;

  // Kiểm tra hôm nay đã check-in chưa
  Future<bool> hasCheckedInToday(String userId) async {
    final snapshot = await _db
        .collection('daily_checkins')
        .where('user_id', isEqualTo: userId)
        .where('check_in_date', isGreaterThanOrEqualTo: _startOfDay(DateTime.now()))
        .where('check_in_date', isLessThan: _endOfDay(DateTime.now()))
        .get();
    return snapshot.docs.isNotEmpty;
  }
  Future<DailyCheckin?> getLastCheckin(String userId) async{
    final snapshot = await _db.collection('daily_checkins')
        .where('user_id', isEqualTo: userId)
        .orderBy('check_in_date', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return DailyCheckin.fromMap(snapshot.docs.single);
    }
    return null;
  }

  // Tạo một bản ghi check-in mới
  Future<void> createCheckIn({
    required String userId,
    required int reward,
    required int streakCount,
  }) async {
    final now = DateTime.now();
    final docRef = await _db.collection('daily_checkins').add({
      'user_id': userId,
      'check_in_date': now,
      'reward': reward,
      'streak_count': streakCount,
    });
    await docRef.update({
      'id':docRef.id
    });

  }

  // Hàm tiện ích lấy đầu ngày, cuối ngày
  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}