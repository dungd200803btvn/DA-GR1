import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lcd_ecommerce_app/data/repositories/user/user_repository.dart';
import 'package:lcd_ecommerce_app/routes/routes.dart';
import 'package:lcd_ecommerce_app/utils/constants/api_constants.dart';
import 'package:lcd_ecommerce_app/utils/local_storage/storage_utility.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/repositories/authentication/authentication_repository.dart';
import 'data/repositories/vouchers/VoucherRepository.dart';
import 'features/notification/controller/notification_controller.dart';
import 'firebase_options.dart';

// Tạo channel cho Android (để hiển thị thông báo ở mức độ cao)
 AndroidNotificationChannel channel = AndroidNotificationChannel(
  Random.secure().nextInt(100000).toString(), // id của channel
  'High Importance Notifications', // tên channel
  description:
  'This channel is used for important notifications.', // mô tả channel
  importance: Importance.max,
);

// Khởi tạo plugin local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Handler cho background messages (nếu cần)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Xử lý background message nếu cần
}

Future<void> main() async {
// Widget binding
final WidgetsBinding widgetsBinding  = WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await DLocalStorage.init("my_bucket");
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then( (FirebaseApp value) {
    Get.put(AuthenticationRepository());
  })  ;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  // Cập nhật token mới lên Firestore cho người dùng hiện tại
  FirebaseFirestore.instance.collection('User').doc(AuthenticationRepository.instance.authUser!.uid).update({'FcmToken': newToken});
});

// Xử lý khi app được mở từ trạng thái terminated (không chạy)
  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // Điều hướng đến màn hình Home khi app được mở qua thông báo
    navigatorKey.currentState?.pushNamed(TRoutes.home);
  }
  // Lắng nghe khi app được mở từ trạng thái background nhờ click thông báo
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState?.pushNamed(TRoutes.home);
  });
  // Cấu hình Android cho local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  // Cấu hình iOS cho local notifications
  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings();
  // Gộp các cài đặt
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  // Khởi tạo plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  Stripe.publishableKey = stripePublicKey;
  runApp(const MyApp());
}
