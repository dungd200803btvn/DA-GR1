import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:app_my_app/data/repositories/notification/notification_repository.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../main.dart';
import '../../../utils/popups/loader.dart';
import '../model/notification_model.dart';

class NotificationController extends GetxController {
static NotificationController get instance => Get.find();
final notificationRepository = NotificationRepository.instance;
final RxInt notificationCount = 0.obs;
StreamSubscription? _notificationSubscription;
void _listenForNotifications() {
  // Hủy listener cũ nếu có
  _notificationSubscription?.cancel();

  String? userId = AuthenticationRepository.instance.authUser?.uid;
  if (userId == null) return;

  _notificationSubscription = FirebaseFirestore.instance
      .collection('User')
      .doc(userId)
      .collection('notifications')
      .where('read', isEqualTo: false)
      .snapshots()
      .listen((snapshot) {
    notificationCount.value = snapshot.docs.length;
  });
}
void resetNotificationCount() {
  notificationCount.value = 0;
}
// Gọi lại hàm này khi user thay đổi
void updateUserNotifications() {
  _listenForNotifications();
}
@override
  void onClose() {
    // TODO: implement onClose
  _notificationSubscription?.cancel();
  super.onClose();
  }
  @override
  void onInit() async{
    super.onInit();
    _listenForNotifications();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      if (kDebugMode) {
        print("user granted permission");
      }
    }else{
      if (kDebugMode) {
        print("user denied permission");
      }
    }
    // Lắng nghe tin nhắn khi ứng dụng đang ở foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification != null && android != null) {
        if (kDebugMode) {
          print("Title: ${notification.title}");
          print("Body: ${notification.body}");
        }
        Future.delayed(Duration.zero,(){
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.high,
                priority: Priority.high,
                playSound: true,
              ),
              iOS: const DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true
              ),
            ),
          );
        });
      }
    });
  }

Future<List<NotificationModel>> getAllNotifications() async {
  try {
    final notifications = await notificationRepository.fetchAllNotifications(AuthenticationRepository.instance.authUser!.uid);
    return notifications;
  } catch (e) {
    TLoader.errorSnackbar(title: 'getAllVouchers() not found', message: e.toString());
    if (kDebugMode) {
      print(e.toString());
    }
    return [];
  }
}
Future<void> markNotificationAsRead(String userId, String notificaitonId) async{
  await notificationRepository.markNotificationAsRead(userId, notificaitonId);
}

}
