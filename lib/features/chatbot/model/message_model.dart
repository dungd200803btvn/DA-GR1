import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_button_model.dart';

class MessageModel {
  final String text;
  final bool isUser;
  final DateTime createdAt;
  final List<ChatButton>? buttons;
  MessageModel({required this.text, required this.isUser, required this.createdAt, this.buttons,});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Tạo đối tượng từ Map (khi đọc từ Firebase)
  factory MessageModel.fromMap(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    DateTime timestamp;
    if (map['createdAt'] is String) {
      timestamp = DateTime.parse(map['createdAt'] as String);
    } else if (map['createdAt'] is Timestamp) {
      timestamp = (map['createdAt'] as Timestamp).toDate();
    } else {
      throw Exception("Invalid timestamp type: ${map['timestamp']}");
    }
    return MessageModel(
      text: map['text'],
      isUser: map['isUser'],
      createdAt: timestamp
    );
  }
}
