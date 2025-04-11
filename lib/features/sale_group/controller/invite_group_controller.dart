import 'package:app_my_app/data/repositories/user/user_repository.dart';
import 'package:app_my_app/features/sale_group/controller/sale_group_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../data/repositories/sale_group/sale_group_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helper/cloud_helper_functions.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loader.dart';
import '../../../utils/singleton/user_singleton.dart';
import '../../notification/controller/notification_service.dart';
import '../model/sale_group_model.dart';

class InviteGroupController extends GetxController {
  static InviteGroupController get instance => Get.find();
  final SaleGroupRepository repository = SaleGroupRepository.instance;
  final UserRepository userRepository = UserRepository.instance;
  late AppLocalizations lang;

  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }

  Future<void> showDeleteConfirmation(BuildContext context, SaleGroupModel group) async {
    final lang = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lang.translate('confirm')),
        content: Text(lang.translate('confirm_delete_group')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await repository.deleteSaleGroup(group);
              await SaleGroupController.instance.fetchSaleGroups();
              TLoader.successSnackbar(title: 'delete_group_message');
              Navigator.pop(context);
              Get.back(); // Quay về màn hình trước
            },
            child: Text(lang.translate('delete')),
          ),
        ],
      ),
    );
  }

  Future<void> sendGroupInvitation(String friendId,BuildContext context,SaleGroupModel group) async {
    TFullScreenLoader.openLoadingDialog(
        'Handle request now...', TImages.loaderAnimation);
    try {
      final friend = await userRepository.getUserById(friendId);
      await userRepository.saveGroupInvitation(friend,group.id);
      String baseMessage = lang.translate(
        'send_invite_group_message',
        args: [
          friend.fullname,
          group.name
        ],
      );
      String baseMessage2 = lang.translate(
        'receive_invite_group_message',
        args: [
          UserSession.instance.userName.toString(),
          group.name
        ],
      );
      String finalMessage = baseMessage.replaceAll(RegExp(r'[{}]'), '');
      String finalMessage2 = baseMessage2.replaceAll(RegExp(r'[{}]'), '');
      String url = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/invite_group.jpg", "invite_group");
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
