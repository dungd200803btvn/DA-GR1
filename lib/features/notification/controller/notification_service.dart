import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:app_my_app/features/notification/controller/get_token.dart';
import 'package:app_my_app/features/notification/model/notification_model.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _userId; // Giả sử bạn có userId của người dùng hiện tại
  NotificationService._internal();

  /// Gọi hàm này sau khi user đăng nhập
  void initialize(String userId) {
    _userId = userId;
  }
  /// Lưu thông báo vào Firestore
  Future<void> saveNotification(NotificationModel notification, String userId) async {
   DocumentReference documentReference =  await _firestore
        .collection('User')
        .doc(userId)
        .collection('notifications')
       .add(notification.toMap());
    await documentReference.update({
      'id':documentReference.id
    });
  }

  /// Phương thức tạo thông báo và lưu lên Firestore, đồng thời gửi push notification qua FCM
  Future<void> createAndSendNotification({
    required String title,
    required String message,
    required String type,
    String? orderId,
    String? imageUrl,
  }) async {
    // Tạo id duy nhất cho thông báo
    final now = DateTime.now();
    final notification = NotificationModel(
      id: '',
      title: title,
      message: message,
      timestamp: now,
      type: type,
      orderId: orderId,
      imageUrl: imageUrl,
    );
    // Lưu thông báo vào Firestore
    await saveNotification(notification,_userId!);
    // Gửi push notification qua FCM (LƯU Ý: Thông thường phải thực hiện từ phía server/Cloud Functions)
    await _sendPushNotification(notification);
  }

  Future<void> _sendPushNotification(NotificationModel notification) async {
    // Lấy FCM token của thiết bị hiện tại (device token)
    final deviceToken = await _messaging.getToken();
    if (kDebugMode) {
      print("accessToken: $deviceToken");
    }
    if (deviceToken == null) return;

    // Thay thế bằng access token bạn đã lấy được từ Service Account
    final accessToken = await getAccessToken();
    print("accessToken: ${accessToken}");
    const String projectId = "da-gr1"; // Thay bằng project ID của bạn nếu cần

    // Tạo payload theo định dạng của FCM HTTP v1 API
    final payload = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": notification.title,
          "body": notification.message,
        },
        "data": {
          "id": notification.id,
          "type": notification.type,
          "orderId": notification.orderId ?? "",
        }
      }
    };

    const url = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Push notification sent successfully");
      }
    } else {
      if (kDebugMode) {
        print("Failed to send push notification: ${response.body}");
      }
    }
  }
   void resetInstance() {
    _userId = null;
  }
  /// Gửi thông báo đến thiết bị cụ thể thông qua FCM token
  Future<void> sendNotificationToDeviceToken({
    required String deviceToken,
    required String title,
    required String message,
    required String type,
    String? orderId,
    String? imageUrl,
    required String friendId,
  }) async {
    final now = DateTime.now();
    final notification = NotificationModel(
      id: '', // Sẽ được gán khi lưu vào Firestore
      title: title,
      message: message,
      timestamp: now,
      type: type,
      orderId: orderId,
      imageUrl: imageUrl,
    );

    // Lưu thông báo vào Firestore của người dùng hiện tại
    await saveNotification(notification,friendId);
    final accessToken = await getAccessToken();
    const String projectId = "da-gr1"; // Project ID của bạn
    final payload = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": title,
          "body": message,
        },
        "data": {
          "type": type,
          "orderId": orderId ?? "",
          "imageUrl": imageUrl ?? "",
        }
      }
    };

    final url = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("✅ Push notification sent to deviceToken: $deviceToken");
      }
    } else {
      if (kDebugMode) {
        print("❌ Failed to send push notification: ${response.body}");
      }
    }
  }

}
