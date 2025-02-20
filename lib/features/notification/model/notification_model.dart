import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
   bool read;
  final String? orderId;
  final String? imageUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.read = false,
    this.orderId,
    this.imageUrl,
  });

  // Chuyển đối tượng thành Map để lưu lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'read': read,
      'orderId': orderId,
      'imageUrl': imageUrl,
    };
  }

  // Tạo đối tượng từ Map (khi đọc từ Firebase)
  factory NotificationModel.fromMap(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    DateTime timestamp;
    if(map['timestamp'] is String){
      timestamp  = DateTime.parse(map['timestamp'] as String);
    }else if(map['timestamp'] is Timestamp){
      timestamp = (map['timestamp'] as Timestamp).toDate();
    } else {
      throw Exception("Invalid timestamp type: ${map['timestamp']}");
    }
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      timestamp: timestamp,
      type: map['type'] as String,
      read: map['read'] as bool,
      orderId: map['orderId'] as String?,
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
