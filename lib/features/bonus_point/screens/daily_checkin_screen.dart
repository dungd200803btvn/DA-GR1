import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:my_app/features/bonus_point/controller/daily_checkin_controller.dart';
import 'package:my_app/l10n/app_localizations.dart';
import 'package:my_app/utils/formatter/formatter.dart';
import 'package:my_app/utils/helper/cloud_helper_functions.dart';
import 'package:my_app/utils/popups/loader.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../authentication/models/user_model.dart';
import '../../notification/controller/notification_service.dart';
import '../../personalization/screens/setting/setting.dart';
import '../model/daily_checkin_item.dart';

class DailyCheckInScreen extends StatefulWidget {
  final UserModel currentUser;
  const DailyCheckInScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final controller = DailyCheckinController.instance;
  bool _loading = false;
  int todayPoints = 0;

  // Danh sách 7 ô ngày
  List<DayCheckItem> dayItems = [];

  @override
  void initState() {
    super.initState();
    _fetchDayItems();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchDayItems();
  }

  /// Lấy streak hôm nay -> tạo danh sách 7 ô
  Future<void> _fetchDayItems() async {
    final lang = AppLocalizations.of(context);
    setState(() => _loading = true);
    try {
      // 1. Xác định hôm nay là streak mấy
      final todayStreak = await controller.getTodayStreak(widget.currentUser.id);
      final todayIndex = todayStreak-1;
      // 2. Kiểm tra đã check-in hôm nay chưa
      final hasChecked = await controller.isDailyCheckin(widget.currentUser.id);
      // 3. Tạo 7 phần tử
      final tempList = <DayCheckItem>[];
      for (int i = 0; i < 7; i++) {
        final dayLabel = (i == todayIndex) ? lang.translate('today') : lang.translate('day') +"${i + 1}";
        final reward = controller.getRewardByStreak(i+1);
        if(i==todayIndex){
          setState(() {
            todayPoints = reward;
          });
        }
        bool isChecked = false;
        if(hasChecked){
          isChecked = i<= todayIndex;
        }else{
          isChecked = i<todayIndex;
        }
        tempList.add(DayCheckItem(
          dayLabel: dayLabel,
          streakValue: i+1,
          reward: reward,
          isCheckedIn: isChecked, // ô đầu là hôm nay
        ));
      }
      setState(() {
        dayItems = tempList;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Loi: $e");
      }

    } finally {
      setState(() => _loading = false);
    }
  }

  /// User ấn nút “Điểm danh ngay”
  Future<void> _onCheckIn(int todayIndex,BuildContext context) async {
    final lang = AppLocalizations.of(context);
    setState(() {
      _loading = true;
    });
    try {
      await controller.handleDailyCheckIn(widget.currentUser.id);
        // Đánh dấu ô đầu tiên (hôm nay) là đã check in
        if (dayItems.isNotEmpty) {
          dayItems[todayIndex].isCheckedIn = true;
        }
        TLoader.successSnackbar(title: lang.translate('today_checkin_success'));
      String baseMessage = lang.translate(
        'checkin_success_msg',
        args: [todayPoints.toString()],
      );
      String finalMessage = baseMessage.replaceAll(RegExp(r'[{}]'), '');
        String url = await  TCloudHelperFunctions.uploadAssetImage("assets/images/content/daily_checkin_success.png", "daily_checkin_success");
        final NotificationService notificationService =
        NotificationService(userId: AuthenticationRepository.instance.authUser!.uid);
        await notificationService.createAndSendNotification(
          title: lang.translate('get_point_success'),
          message: finalMessage,
          type: "points",
          imageUrl: url,
        );
    } catch (e) {
      TLoader.warningSnackbar(title: lang.translate('today_checkin_duplicate'));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    final DateTime today = DateTime.now();
    final expiredDay = today.add(Duration(days: 30));

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(lang.translate('get_bonus_points'),style: Theme.of(context).textTheme.headlineSmall, ),
        leadingOnPressed: ()=> Get.to(const SettingScreen()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phần Header: Greeting và current bonus points
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${lang.translate('hello')}, ${widget.currentUser.fullname}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${lang.translate('current_bonus_points')}: ${widget.currentUser.points}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Nút "Today Checkin Now" được thiết kế đẹp
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () async {
                  // Truyền streak index theo logic của bạn
                  _onCheckIn(await controller.getTodayStreak(widget.currentUser.id) - 1, context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(lang.translate('today_checkin_now')),
              ),
            ),
            SizedBox(height: 16),
            // Phần Orange: Thông tin bonus expire và 7 ô check-in
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.currentUser.points} ${lang.translate('bonus_points_expire')} ${DFormatter.FormattedDate1(expiredDay)}",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 16),
                  // Danh sách 7 ô check-in với thiết kế
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(dayItems.length, (index) {
                        final item = dayItems[index];
                        final bgColor = item.isCheckedIn ? Colors.white : Colors.transparent;
                        final textColor = item.isCheckedIn ? Colors.orange : Colors.white;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white70),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "+${item.reward}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Icon(
                                      item.isCheckedIn ? Icons.check_circle : Icons.monetization_on,
                                      color: item.isCheckedIn ? Colors.green : Colors.yellow,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item.dayLabel,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 16),
                  // (Bạn có thể thêm nút "Nhận thêm 600 hôm nay!" nếu cần)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
