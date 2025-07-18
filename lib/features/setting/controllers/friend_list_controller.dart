import 'package:app_my_app/features/sale_group/model/friend_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../l10n/app_localizations.dart';

class FriendListController extends GetxController {
  static FriendListController get instance => Get.find();
  final String currentUserId = AuthenticationRepository.instance.authUser!.uid;
  final UserRepository userRepository = UserRepository.instance;
  RxList<FriendModel> friends = <FriendModel>[].obs;
  RxBool isLoading = true.obs;
  late AppLocalizations lang;

  @override
  void onInit() {
    super.onInit();
    loadFriends();
  }

  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }

  Future<void> loadFriends() async {
    try {
      isLoading.value = true;
      List<FriendModel> fetchedUsers = await userRepository.getAllFriends();
      friends.assignAll(fetchedUsers);
    } catch (e) {
      print("Error fetching friends: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
