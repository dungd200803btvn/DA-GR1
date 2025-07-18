import 'package:app_my_app/features/chatbot/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ChatbotRepository extends GetxController {
  static ChatbotRepository get instance => Get.find();
  //variables
  final _db = FirebaseFirestore.instance;
  Future<void> saveMessageToFirestore(String userId, MessageModel message) async {
    await _db
        .collection('User')
        .doc(userId)
        .collection('chatbot')
        .add(message.toJson());
  }

  Future<List<MessageModel>> fetchAllMessagesByUser(String userId) async {
    try {
      final result = await _db.collection('User').doc(userId).collection('chatbot').orderBy('createdAt', descending: false).get();
      return result.docs.map((doc) => MessageModel.fromMap(doc)).toList();
    } catch (e) {
      throw 'Error fetching notifications: $e';
    }
  }
}
