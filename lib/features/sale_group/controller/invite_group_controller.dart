import 'dart:io';

import 'package:app_my_app/data/repositories/user/user_repository.dart';
import 'package:app_my_app/features/sale_group/controller/sale_group_controller.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
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
  Future<Uri> createGroupDynamicLink(SaleGroupModel group) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://ecommerce200803.page.link',
      link: Uri.parse('https://ecommerce200803.page.link/group/${group.id}'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.ecommerce_app',
        fallbackUrl: Uri.parse('https://appdistribution.firebase.dev/i/e8414077a97b5ef7'),
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortLink.shortUrl;
  }
  void showQrCodeDialog(BuildContext context, String data) {
    final screenshotController = ScreenshotController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mã QR nhóm'),
          content: Screenshot(
            controller: screenshotController,
            child: QrImageView(
              data: data,
              size: 200,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final image = await screenshotController.capture();
                if (image != null) {
                  final tempDir = await getTemporaryDirectory();
                  final file = await File('${tempDir.path}/qr.png').create();
                  await file.writeAsBytes(image);
                  Share.shareFiles([file.path], text: 'Tham gia nhóm săn sale!');
                }
                Navigator.pop(context);
              },
              child: Text('Chia sẻ'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void showShareOptions(BuildContext context, SaleGroupModel group) async {
    final Uri dynamicLink = await createGroupDynamicLink(group);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.link),
              title: Text('Chia sẻ liên kết'),
              onTap: () {
                Share.share('Tham gia nhóm săn sale "${group.name}": $dynamicLink');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code),
              title: Text('Chia sẻ mã QR'),
              onTap: () {
                Navigator.pop(context);
                showQrCodeDialog(context, dynamicLink.toString());
              },
            ),
          ],
        );
      },
    );
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
