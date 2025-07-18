import 'package:app_my_app/features/chatbot/model/message_model.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../data/repositories/chatbot/chatbot_repository.dart';

class ChatbotController extends GetxController {
  static ChatbotController get instance => Get.find();
  final ChatbotRepository chatbotRepository = ChatbotRepository.instance;
  Future<void> saveMessageToFirestore(String userId, MessageModel message) async {
   await chatbotRepository.saveMessageToFirestore(userId, message);
  }
  Future<List<MessageModel>> fetchAllMessagesByUser(String userId) async{
  return  await chatbotRepository.fetchAllMessagesByUser(userId);
  }

}