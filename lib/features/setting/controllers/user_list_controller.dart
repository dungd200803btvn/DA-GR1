import 'package:app_my_app/data/repositories/user/user_repository.dart';
import 'package:app_my_app/features/notification/controller/notification_service.dart';
import 'package:app_my_app/features/sale_group/model/friend_model.dart';
import 'package:app_my_app/utils/singleton/user_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helper/cloud_helper_functions.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loader.dart';
import '../../authentication/models/user_model.dart';

class UserListController extends GetxController {
  static UserListController get instance => Get.find();
  final String currentUserId = AuthenticationRepository.instance.authUser!.uid;
  final UserRepository userRepository =  UserRepository.instance;
  RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> _allUsers = <UserModel>[].obs;
  final searchQuery = ''.obs;
  RxBool isLoading = true.obs;
  late AppLocalizations lang;
  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      List<UserModel> fetchedUsers = await userRepository.getAllUsers();
      List<FriendModel> friends = await userRepository.getAllFriends();
      final friendIds = friends.map((friend)=> friend.friendId).toSet();
      fetchedUsers = fetchedUsers.where((user) => user.id != currentUserId && !friendIds.contains(user.id)).toList();
      users.assignAll(fetchedUsers);
      _allUsers.assignAll(fetchedUsers);
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      users.assignAll(_allUsers);
    } else {
      final lowerQuery = query.toLowerCase();
      users.assignAll(_allUsers.where((user) =>
          user.fullname.toLowerCase().startsWith(lowerQuery) ||
          user.email.toLowerCase().startsWith(lowerQuery)));
    }
  }

  /// Gửi lời mời kết bạn
  Future<void> sendFriendInvitation(UserModel friend,BuildContext context) async {
    TFullScreenLoader.openLoadingDialog(
        'Handle request now...', TImages.loaderAnimation);
    try {
        await userRepository.saveFriendInvitation(friend);
        String baseMessage = lang.translate(
          'send_inviation_success_message',
          args: [
            friend.fullname
          ],
        );
        String baseMessage2 = lang.translate(
          'receive_inviation_success_message',
          args: [
            UserSession.instance.userName.toString()
          ],
        );
        String finalMessage = baseMessage.replaceAll(RegExp(r'[{}]'), '');
        String finalMessage2 = baseMessage2.replaceAll(RegExp(r'[{}]'), '');
        String url = await TCloudHelperFunctions.uploadAssetImage(
            "assets/images/content/add_friend.jpg", "add_friend");
        await NotificationService.instance.createAndSendNotification(
            title: lang.translate('send_inviation_title'),
            message: finalMessage,
            type: 'send_request',
            imageUrl: url);
       await NotificationService.instance.sendNotificationToDeviceToken(
          deviceToken: friend.fcmToken,
          title: lang.translate('receive_inviation_title'),
          message: finalMessage2,
          type: 'send_request',
          imageUrl: url,
          friendId: friend.id);
    } catch (e) {
      if (kDebugMode) {
        print("Error in sendFriendInvitation: $e");
      }
    }finally{
      TLoader.successSnackbar(title: lang.translate('send_inviation_title'));
      TFullScreenLoader.stopLoading();
      Navigator.pop(context);
    }
  }
}