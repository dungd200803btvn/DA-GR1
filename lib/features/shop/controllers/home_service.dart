import 'package:app_my_app/data/repositories/sale_group/sale_group_repository.dart';
import 'package:app_my_app/data/repositories/user/user_repository.dart';
import 'package:app_my_app/utils/popups/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/vouchers/ClaimedVoucherRepository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helper/cloud_helper_functions.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../notification/controller/notification_service.dart';
import '../../sale_group/controller/sale_group_controller.dart';
import '../../voucher/models/UserClaimedVoucher.dart';
import '../../voucher/models/VoucherModel.dart';

class HomeService {
  static final HomeService instance = HomeService._internal();
  HomeService._internal();
  void handleDynamicLinks(BuildContext context) async {
    // Khi app đang mở
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
      final Uri deepLink = data.link;
      print('Link nhận được: ${data.link}');
      TLoader.customToast(message: 'Link nhận được: ${data.link}');
      _handleGroupLink(deepLink, context);
    });
    // Khi app mở bằng link (chưa mở sẵn)
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    if (data?.link != null) {
      _handleGroupLink(data!.link, context);
    }
  }
  void _handleGroupLink(Uri uri, BuildContext context) {
    // Nếu dùng /join/abc123
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == "group"){
      final groupId = segments[1];
      TLoader.customToast(message: 'Groupid: $groupId');
      print("Groupid: $groupId");
      _showJoinGroupPopup(groupId, context);
    } else {
      TLoader.customToast(message: 'Không tìm thấy groupId trong URI');
    }
  }
  // void _showJoinGroupPopup(String groupId, BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (_) => JoinGroupPage(groupId: groupId),
  //     ),
  //   );
  // }
  Future<void> _showJoinGroupPopup(String groupId, BuildContext context) async {
    final SaleGroupRepository groupRepository = SaleGroupRepository.instance;
    final UserRepository userRepository = UserRepository.instance;
    final ClaimedVoucherRepository claimedVoucherRepository =
        ClaimedVoucherRepository.instance;
    // Lấy dữ liệu nhóm từ Firestore hoặc API
    final group = await groupRepository.getSaleGroupById(groupId);
    final navigator = Navigator.of(context);// bạn cần tự tạo hàm này
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tham gia nhóm: ${group.name}'),
          content: Text(group.name),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                TFullScreenLoader.openLoadingDialog(
                    'Handle request now...', TImages.loaderAnimation);

                try{
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  print("Gia tri cua user hien tai: $userId");
                  if (userId != null) {
                    final completed = await groupRepository.addUserToGroup(group.id, userId);
                    print("Gia tri cua completed:$completed");
                    if(completed){
                      final String completeMessage =
                          "Nhóm ${group.name} đã đủ thành viên và kích hoạt voucher mua sắm theo nhóm!";
                      final String completedImageUrl =
                      await TCloudHelperFunctions.uploadAssetImage(
                          "assets/images/content/full_member.jpg", "full_member");
                      final String groupVoucherImageUrl =
                      await TCloudHelperFunctions.uploadAssetImage(
                          "assets/images/content/group_voucher.jpg", "group_voucher");
                      final groupAfterAddUser = await groupRepository.getSaleGroupById(groupId);
                      for (final userId in groupAfterAddUser.participants) {
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

                      final claimedVoucher = ClaimedVoucherModel(
                          voucherId: voucherId, claimedAt: Timestamp.now(), isUsed: false);
                      for(final userId in groupAfterAddUser.participants ){
                        await claimedVoucherRepository.claimVoucher(userId, claimedVoucher);
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
                    }
                    await SaleGroupController.instance.fetchSaleGroups();
                  }
                }catch (e) {
                  if (kDebugMode) {
                    print("Error in join group: $e");
                  }
                }finally{
                  TLoader.successSnackbar(title: 'Đã tham gia nhóm thành công');
                  TFullScreenLoader.stopLoading();
                  navigator.pop();
                }
              },
              child: Text('Tham gia nhóm'),
            ),
          ],
        );
      },
    );
  }
}
