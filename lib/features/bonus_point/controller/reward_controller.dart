import 'dart:async';

import 'package:app_my_app/data/repositories/vouchers/VoucherRepository.dart';
import 'package:app_my_app/features/voucher/models/VoucherModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helper/cloud_helper_functions.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loader.dart';
import '../../notification/controller/notification_service.dart';

class RewardController extends GetxController {
  static RewardController get instance => Get.find();
  RxList<VoucherModel> vouchers = <VoucherModel>[].obs;
  final VoucherRepository voucherRepository = VoucherRepository.instance;
  late AppLocalizations lang;
  @override
  void onInit() {
    fetchVouchers();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }

  Future<void> fetchVouchers() async{
    try{
      final voucher = await voucherRepository.fetchRedeemableByPointVouchers();
      vouchers.assignAll(voucher);
    }catch(e){
      print('Error in fetchVouchers() in RewardController : $e');
    }
  }

  Future<void> exchangeReward(String userId, VoucherModel voucher) async{
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final voucherId = voucher.id;
    final requiredPoints = voucher.pointsToRedeem;
    final userDocRef = firestore.collection('User').doc(userId);
    final claimedVouchersRef = userDocRef.collection('claimed_vouchers');
    final startTime =  DateTime.now();
    TFullScreenLoader.openLoadingDialog(
        'Exchange reward now...', TImages.loaderAnimation);
    try {
      final userSnapshot = await userDocRef.get();
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final currentPoints = userData['points'] ?? 0;

      if (currentPoints < requiredPoints) {
        TLoader.warningSnackbar(title: 'Bạn không đủ điểm để đổi voucher này.');
        return;
      }
      // Trừ điểm và lưu voucher vào bảng claimed_vouchers
      await firestore.runTransaction((transaction) async {
        transaction.update(userDocRef, {
          'points': currentPoints - requiredPoints,
        });

        transaction.set(claimedVouchersRef.doc(), {
          'voucher_id': voucherId,
          'claimed_at': FieldValue.serverTimestamp(),
          'is_used': false,
          'used_at': null,
        });
        // Ghi log vào bảng reward_items
        final rewardLogRef = userDocRef.collection('reward_items').doc();
        transaction.set(rewardLogRef, {
          'voucher_id': voucherId,
          'points_used': requiredPoints,
          'redeemed_at': FieldValue.serverTimestamp(),
        });
      });

      TLoader.successSnackbar(title: 'Đổi thưởng thành công!');
      // 🔄 Gửi thông báo sau khi giao dịch thành công (async)
      unawaited(_sendExchangeNotification(voucher));
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("🔥 Thời gian doi thuong: ${duration.inMilliseconds}ms");
    } catch (e) {
      print("Error during redeem: $e");
      TLoader.errorSnackbar(title: 'Có lỗi xảy ra, vui lòng thử lại.');
    }finally {
      TFullScreenLoader.stopLoading();
    }
  }

  Future<void> _sendExchangeNotification(VoucherModel voucher) async {
    try {
      String baseMessage = lang.translate(
          'exchange_rewards_msg', args: [voucher.description]);
      String finalMessage = baseMessage.replaceAll(RegExp(r'[{}]'), '');
      String url = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/exchange_reward.jpg", "exchange_reward");
      await NotificationService.instance.createAndSendNotification(
        title: lang.translate('exchange_rewards'),
        message: finalMessage,
        type: "exchange rewards",
        imageUrl: url,
      );
    } catch (e) {
      print("🔴 Gửi thông báo thất bại: $e");
    }
  }
}
