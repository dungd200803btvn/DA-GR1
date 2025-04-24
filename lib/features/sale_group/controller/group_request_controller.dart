import 'package:app_my_app/features/sale_group/controller/sale_group_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../data/repositories/sale_group/sale_group_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/enum/enum.dart';
import '../../../utils/helper/cloud_helper_functions.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loader.dart';
import '../../../utils/singleton/user_singleton.dart';
import '../../notification/controller/notification_service.dart';
import '../../voucher/models/VoucherModel.dart';
import '../model/group_request_model.dart';

class GroupRequestController extends GetxController {
  static GroupRequestController get instance => Get.find();
  final RxList<GroupRequestModel> requests = <GroupRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final UserRepository userRepository = UserRepository.instance;
  final SaleGroupRepository saleGroupRepository = SaleGroupRepository.instance;

  String get currentUserId => UserSession.instance.userId!;
  late AppLocalizations lang;

  @override
  void onInit() {
    super.onInit();
    fetchGroupRequests();
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }

  Future<void> fetchGroupRequests() async {
    try {
      isLoading.value = true;
      final fetchedRequests = await userRepository.fetchGroupRequests();
      requests.assignAll(fetchedRequests);
    } catch (e) {
      print("Error fetchFriendRequests() in FriendRequestsController: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGroupRequestStatus(GroupRequestModel groupRequest,
      String newStatus, BuildContext context) async {
    TFullScreenLoader.openLoadingDialog(
        'Handle request now...', TImages.loaderAnimation);
    try {
      requests.removeWhere((req) => req.id == groupRequest.id);
      final result = await userRepository.updateGroupRequestStatus(
          groupRequest.id, newStatus);
      await SaleGroupController.instance.fetchSaleGroups();
      final fromUser =
          await userRepository.getUserById(groupRequest.fromUserId);
      String baseMessage = lang.translate(
        'accept_group_invite_message',
        args: [UserSession.instance.userName.toString()],
      );
      String baseMessage2 = lang.translate(
        'reject_group_invite_message',
        args: [UserSession.instance.userName.toString()],
      );
      String finalMessage = baseMessage.replaceAll(RegExp(r'[{}]'), '');
      String finalMessage2 = baseMessage2.replaceAll(RegExp(r'[{}]'), '');
      String url = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/accept_request.jpg", "accept_request");
      String url2 = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/reject_request.jpg", "reject_request");
      switch (result) {
        case GroupRequestResult.alreadyMember:
          TLoader.warningSnackbar(
              title: "Bạn đã là thành viên của nhóm này rồi.");
          break;
        case GroupRequestResult.accepted:
          TLoader.successSnackbar(title: "Bạn đã tham gia nhóm thành công!");
          break;
        case GroupRequestResult.rejected:
          TLoader.successSnackbar(title: "Bạn đã từ chối lời mời nhóm.");
          break;
        case GroupRequestResult.error:
          TLoader.errorSnackbar(title: "Có lỗi xảy ra. Vui lòng thử lại.");
          break;
        case GroupRequestResult.completed:
          // Lấy thông tin nhóm
          final group =
              await saleGroupRepository.getSaleGroupById(groupRequest.groupId);
          final String completeMessage =
              "Nhóm ${group.name} đã đủ thành viên và kích hoạt voucher mua sắm theo nhóm!";
          final String completedImageUrl =
              await TCloudHelperFunctions.uploadAssetImage(
                  "assets/images/content/full_member.jpg", "full_member");
          final String groupVoucherImageUrl =
              await TCloudHelperFunctions.uploadAssetImage(
                  "assets/images/content/group_voucher.jpg", "group_voucher");
          for (final userId in group.participants) {
            try {
              final user = await userRepository.getUserById(userId);
                await NotificationService.instance
                    .sendNotificationToDeviceToken(
                  deviceToken: user.fcmToken,
                  title: "Nhóm đã hoàn tất!",
                  message: completeMessage,
                  type: 'group_completed',
                  imageUrl: completedImageUrl,
                  friendId: userId,
                );
            } catch (e) {
              print("Lỗi gửi thông báo đến user $userId: $e");
            }
          }
          // 3. Tạo voucher mới
          final String voucherId =
              FirebaseFirestore.instance.collection('voucher').doc().id;
          final Timestamp now = Timestamp.now();
          final Timestamp endDate = Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 30)),
          );
          String type = '';
          if (group.brandId != null) {
            type = 'brand';
          } else if (group.shopId != null) {
            type = 'shop';
          } else {
            type = 'category';
          }
          final voucher = VoucherModel(
            id: voucherId,
            title: "Voucher nhóm ${group.name}",
            description:
            "Giảm ngay ${group.discount}% cho đơn hàng thuộc danh mục $type ${group.selectedObjectName} dành riêng cho thành viên nhóm ${group.name}",
            type: "group_voucher",
            discountValue: group.discount,
            maxDiscount: null,
            minimumOrder: null,
            requiredPoints: null,
            applicableUsers: group.participants,
            applicableProducts: null,
            applicableCategories: null,
            shopId: group.shopId,
            brandId: group.brandId,
            categoryId: group.categoryId,
            startDate: now,
            endDate: endDate,
            quantity: group.participants.length,
            remainingQuantity: group.participants.length,
            claimedUsers: [],
            isActive: true,
            createdAt: now,
            updatedAt: now,
            isRedeemableByPoint: false
          );
          await FirebaseFirestore.instance
              .collection('voucher')
              .doc(voucherId)
              .set(voucher.toJson());
          print(
              "🎉 Voucher đã được tạo cho nhóm ${group.name} với ID: $voucherId");

        for(final userId in group.participants ){
          final user = await userRepository.getUserById(userId);
          await NotificationService.instance.sendNotificationToDeviceToken(
            deviceToken: user.fcmToken,
            title: "Voucher đã được tạo cho nhóm ${group.name}",
            message:
            "Giảm ngay ${group.discount}% cho đơn hàng thuộc danh mục $type ${group.selectedObjectName} dành riêng cho thành viên nhóm ${group.name} ",
            type: 'group_completed',
            imageUrl: groupVoucherImageUrl,
            friendId: userId,
          );
        }
        
          break;
      }
      if (newStatus == 'accepted') {
        await NotificationService.instance.sendNotificationToDeviceToken(
            deviceToken: fromUser.fcmToken,
            title: lang.translate('accept_request'),
            message: finalMessage,
            type: 'update_request',
            imageUrl: url,
            friendId: groupRequest.fromUserId);
      } else {
        await NotificationService.instance.sendNotificationToDeviceToken(
            deviceToken: fromUser.fcmToken,
            title: lang.translate('reject_request'),
            message: finalMessage2,
            type: 'update_request',
            imageUrl: url2,
            friendId: groupRequest.fromUserId);
      }
    } catch (e) {
      print('Error in updateRequestStatus in Request Controller: $e ');
    } finally {
      TFullScreenLoader.stopLoading();
      Navigator.pop(context);
    }
  }
}
