import 'package:get/get.dart';
import 'package:app_my_app/data/repositories/bonus_point/daily_checkin_repository.dart';
import 'package:app_my_app/data/repositories/user/user_repository.dart';

class DailyCheckinController extends GetxController{
  static DailyCheckinController get instance => Get.find();
  final DailyCheckInRepository dailyCheckInRepository = DailyCheckInRepository.instance;
  final UserRepository userRepository = UserRepository.instance;

  Future<bool> isDailyCheckin(String userId) async{
    return await dailyCheckInRepository.hasCheckedInToday(userId);
  }

  Future<int> getTodayStreak(String userId)async{
    final today = DateTime.now();
    final lastCheckIn = await dailyCheckInRepository.getLastCheckin(userId);
    int newStreak = 1;
    // Kiểm tra nếu lastCheckInDate là hôm qua => streak++
    final yesterday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 1));
    if(lastCheckIn!=null){
      if (_isSameDate(lastCheckIn.checkInDate, yesterday)) {
        newStreak = lastCheckIn.streakCount + 1;
      }else if(_isSameDate(lastCheckIn.checkInDate, today)){
        newStreak = lastCheckIn.streakCount;
      }
    }
    return newStreak;
  }

  Future<void> handleDailyCheckIn(String userId) async {
    // 1. Kiểm tra đã check-in hôm nay chưa
    final hasChecked = await isDailyCheckin(userId);
    if (hasChecked) {
      throw Exception("Hôm nay bạn đã check-in rồi!");
    }
    // 2. Tính streak
    final today = DateTime.now();
    final lastCheckIn = await dailyCheckInRepository.getLastCheckin(userId);
    int newStreak = 1;

    // Kiểm tra nếu lastCheckInDate là hôm qua => streak++
    final yesterday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 1));
      if(lastCheckIn!=null){
        if (_isSameDate(lastCheckIn.checkInDate, yesterday)) {
          newStreak = lastCheckIn.streakCount + 1;
        }
      }


    // 3. Tính reward theo streak
    final reward = getRewardByStreak(newStreak);
    // 4. Tạo bản ghi daily_checkins
    await dailyCheckInRepository.createCheckIn(
      userId: userId,
      reward: reward,
      streakCount: newStreak,
    );

    // 5. Cập nhật user (điểm + streak + lastCheckInDate)
    await userRepository.updateUserPoints(
     userId,reward
    );
  }

  bool _isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  int getRewardByStreak(int streak) {
    switch (streak) {
      case 1:
        return 10;
      case 2:
        return 20;
      case 3:
        return 30;
      case 4:
        return 50;
      case 5:
        return 70;
      case 6:
        return 90;
      case 7:
        return 120;
      default:
      // Nếu streak > 7, bạn có thể cho tiếp 120 hoặc tăng dần
        return 120;
    }
  }
}