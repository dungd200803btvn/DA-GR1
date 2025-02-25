import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:t_store/utils/formatter/formatter.dart';
import 'package:t_store/utils/popups/loader.dart';
import '../../../common/widgets/success_screen/success_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation_menu.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../notification/controller/notification_service.dart';

class StripeService{
  StripeService._();
  static final StripeService instance =  StripeService._();

  Future<void> makePayment(double amount, String currency,String userId,String orderId,BuildContext context)async{
    final lang = AppLocalizations.of(context);
    try{

      String? result = await _createPaymentIntent(amount,
          currency);
        if(result== null) return;
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: result,
              merchantDisplayName: "Le Chi Dung"
            ));
        await processPayment();
      TFullScreenLoader.stopLoading();
      Get.off(() => SuccessScreen(
          image: TImages.orderCompletedAnimation,
          title: lang.translate('payment_success'),
          subTitle: lang.translate('ship_soon'),
          onPressed: () async {
            Get.offAll(() => const NavigationMenu());
          }
      ));
      final now = DateTime.now();
      final formattedTime = DateFormat('HH:mm dd/MM/yyyy').format(now);
      final NotificationService notificationService = NotificationService(userId: userId);
      await notificationService.createAndSendNotification(
        title: "Đặt hàng thành công",
        message: "Đơn hàng của bạn đã được đặt thành công vào $formattedTime",
        type: "order",
        orderId: orderId, // nếu có
      );
    }catch(e){
      if (kDebugMode) {
        print(e);
      }
      TFullScreenLoader.stopLoading();
      TLoader.warningSnackbar(title: lang.translate('warning_payment_cancel'));
    }
  }

  Future<void> processPayment() async {
    try {
      // Gọi Payment Sheet của Stripe
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      // Nếu người dùng hủy (bấm X) hoặc chưa nhập đủ thông tin
      if (e.error.localizedMessage?.toLowerCase().contains("cancel") ?? false) {
        // Ném lỗi để flow payment không tiếp tục
        throw Exception("Thanh toán bị hủy bởi người dùng");
      } else {
        throw e;
      }
    }
  }

  Future<String?> _createPaymentIntent(double amount,String currency) async{
     try{
       final Dio dio = Dio();
       if (kDebugMode) {
         print("Gia tri amount: ${DFormatter.calculateAmountForStripe(amount)}");
       }

       Map<String,dynamic> data = {
         "amount": DFormatter.calculateAmountForStripe(amount),
         "currency":currency
       };
       final response = await dio.post(
           'https://api.stripe.com/v1/payment_intents',
       data: data,
       options: Options(
         contentType: Headers.formUrlEncodedContentType,
         headers: {
           "Authorization":"Bearer $stripeSecretKey",
           "Content-Type" :'application/x-www-form-urlencoded'
         }
       ));
       if(response.data!=null){
         if (kDebugMode) {
           print(response.data);
         }
         return response.data['client_secret'];
       }
       return null;

     }catch(e){
        if (kDebugMode) {
          print(e);
        }
     }

  }

  Future<String?> _getListPaymentIntent() async {
    try {
      final Dio dio = Dio();

      final response = await dio.get(
        'https://api.stripe.com/v1/payment_intents',
        queryParameters: {'limit': 3}, // Thêm tham số limit=3
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded'
          },
        ),
      );

      if (response.data != null) {
        if (kDebugMode) {
          print(response.data);
        }
        // Nếu muốn trả về String, có thể dùng jsonEncode hoặc .toString()
        return response.data.toString();
        // hoặc: return response.data.toString();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }


}