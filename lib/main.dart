import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get_storage/get_storage.dart';
import 'package:app_my_app/routes/routes.dart';
import 'package:app_my_app/utils/constants/api_constants.dart';
import 'package:app_my_app/utils/local_storage/storage_utility.dart';
import 'package:http/http.dart' as http;
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'bindings/general_bindings.dart';
import 'data/repositories/authentication/authentication_repository.dart';
import 'firebase_options.dart';
// Tạo channel cho Android (để hiển thị thông báo ở mức độ cao)
AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
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

await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

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

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final data = message.data;
    final title = data['title'] ?? '';
    final body = data['body'] ?? '';
    final imageUrl = data['imageUrl'];

    ByteArrayAndroidBitmap? bigPicture;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          bigPicture = ByteArrayAndroidBitmap(response.bodyBytes);
        }
      } catch (e) {
        print("❌ Lỗi tải ảnh từ URL: $e");
      }
    }

    final NotificationDetails notificationDetails;

    if (bigPicture != null) {
      final androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigPictureStyleInformation(
          bigPicture,
          contentTitle: title,
          summaryText: body,
        ),
      );
      notificationDetails = NotificationDetails(android: androidDetails);
    } else {
      final androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
      );
      notificationDetails = NotificationDetails(android: androidDetails);
    }

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  });

  Stripe.publishableKey = stripePublicKey;
  GeneralBindings().dependencies();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
