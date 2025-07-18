import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/repositories/sale_group/sale_group_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../data/repositories/vouchers/ClaimedVoucherRepository.dart';
import '../../../../utils/helper/cloud_helper_functions.dart';
import '../../../notification/controller/notification_service.dart';
import '../../../sale_group/controller/sale_group_controller.dart';
import '../../../sale_group/model/sale_group_model.dart';
import '../../../voucher/models/UserClaimedVoucher.dart';
import '../../../voucher/models/VoucherModel.dart';

class JoinGroupPage extends StatefulWidget {
  final String groupId;

  const JoinGroupPage({super.key, required this.groupId});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  late Future<SaleGroupModel> _groupFuture;

  @override
  void initState() {
    super.initState();
    _groupFuture = SaleGroupRepository.instance.getSaleGroupById(widget.groupId);
  }

  Future<void> _handleJoinGroup(SaleGroupModel group) async {
    final groupRepository = SaleGroupRepository.instance;
    final userRepository = UserRepository.instance;
    final ClaimedVoucherRepository claimedVoucherRepository =
        ClaimedVoucherRepository.instance;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;
    final completed = await groupRepository.addUserToGroup(group.id, userId);
    await SaleGroupController.instance.fetchSaleGroups();
    if (completed) {
      final completeMessage =
          "Nhóm ${group.name} đã đủ thành viên và kích hoạt voucher mua sắm theo nhóm!";
      final completedImageUrl = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/full_member.jpg", "full_member");
      final groupVoucherImageUrl = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/group_voucher.jpg", "group_voucher");

      final groupAfterAddUser = await groupRepository.getSaleGroupById(widget.groupId);
      for (final userId in groupAfterAddUser.participants) {
        try {
          final user = await userRepository.getUserById(userId);
          await NotificationService.instance.sendNotificationToDeviceToken(
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

      final voucherId =
          FirebaseFirestore.instance.collection('voucher').doc().id;
      final Timestamp now = Timestamp.now();
      final Timestamp endDate =
      Timestamp.fromDate(DateTime.now().add(const Duration(days: 30)));
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
        isRedeemableByPoint: false,
      );

      await FirebaseFirestore.instance
          .collection('voucher')
          .doc(voucherId)
          .set(voucher.toJson());
      final claimedVoucher = ClaimedVoucherModel(
          voucherId: voucherId, claimedAt: Timestamp.now(), isUsed: false);

      for (final userId in groupAfterAddUser.participants) {
        await claimedVoucherRepository.claimVoucher(userId, claimedVoucher);
        final user = await userRepository.getUserById(userId);
        await NotificationService.instance.sendNotificationToDeviceToken(
          deviceToken: user.fcmToken,
          title: "Voucher đã được tạo cho nhóm ${group.name}",
          message:
          "Giảm ngay ${group.discount}% cho đơn hàng thuộc danh mục $type ${group.selectedObjectName} dành riêng cho thành viên nhóm ${group.name}",
          type: 'group_completed',
          imageUrl: groupVoucherImageUrl,
          friendId: userId,
        );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tham gia nhóm thành công')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tham gia nhóm')),
      body: FutureBuilder<SaleGroupModel>(
        future: _groupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy nhóm.'));
          }
          final group = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tên nhóm: ${group.name}",
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                Text("Mô tả: ${group.selectedObjectName ?? 'Không có'}"),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleJoinGroup(group),
                    child: const Text('Tham gia nhóm'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
