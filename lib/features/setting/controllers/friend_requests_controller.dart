import 'package:app_my_app/data/repositories/user/user_repository.dart';
import 'package:app_my_app/features/notification/controller/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helper/cloud_helper_functions.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loader.dart';
import '../../../utils/singleton/user_singleton.dart';
import '../../sale_group/model/friend_request_model.dart';
import 'friend_list_controller.dart';

class FriendRequestsController extends GetxController {
  static FriendRequestsController get instance => Get.find();
  final RxList<FriendRequestModel> requests = <FriendRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final UserRepository userRepository = UserRepository.instance;
  // currentUserId có thể lấy từ UserSession hoặc AuthenticationRepository
  String get currentUserId => UserSession.instance.userId!;
  late AppLocalizations lang;

  @override
  void onInit() {
    super.onInit();
    fetchFriendRequests();
  }

  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }


  Future<void> fetchFriendRequests() async {
    try {
      isLoading.value = true;
      final fetchedRequests = await userRepository.fetchFriendRequests();
      print("Fetched requests count: ${fetchedRequests.length}"); // Debug: số lượng lời mời đã lấy
      requests.assignAll(fetchedRequests);
      print("Controller requests count after assign: ${requests.length}");
    } catch (e) {
      print("Error fetchFriendRequests() in FriendRequestsController: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateRequestStatus(
    String requestId,
     String newStatus,
     String friendId,
      BuildContext context
  ) async {
    TFullScreenLoader.openLoadingDialog(
        'Handle request now...', TImages.loaderAnimation);
    try{
      requests.removeWhere((req)=> req.id==requestId);
      await userRepository.updateFriendRequestStatus(requestId,newStatus);
      await FriendListController.instance.loadFriends();
      final fromUser = await userRepository.getUserById(friendId);
      String baseMessage = lang.translate(
        'accept_request_message',
        args: [
          UserSession.instance.userName.toString()
        ],
      );
      String baseMessage2 = lang.translate(
        'reject_request_message',
        args: [
          UserSession.instance.userName.toString()
        ],
      );
      String finalMessage = baseMessage.replaceAll(RegExp(r'[{}]'), '');
      String finalMessage2 = baseMessage2.replaceAll(RegExp(r'[{}]'), '');
      String url = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/accept_request.jpg", "accept_request");
      String url2 = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/reject_request.jpg", "reject_request");
      if(newStatus=='accepted'){
        await NotificationService.instance.sendNotificationToDeviceToken(
            deviceToken: fromUser.fcmToken,
            title: lang.translate('accept_request'),
            message: finalMessage,
            type: 'update_request',
            imageUrl: url ,
            friendId: friendId);
      }else{
        await NotificationService.instance.sendNotificationToDeviceToken(
            deviceToken: fromUser.fcmToken,
            title: lang.translate('reject_request'),
            message: finalMessage2,
            type: 'update_request',
            imageUrl: url2 ,
            friendId: friendId);
      }
    }catch(e){
      print('Error in updateRequestStatus in Request Controller: $e ');
    }finally{
      if(newStatus=='accepted'){
        TLoader.successSnackbar(title: lang.translate('accept_request'));
      }else{
        TLoader.successSnackbar(title: lang.translate('reject_request'));
      }
      TFullScreenLoader.stopLoading();
      Navigator.pop(context);
    }

  }
}