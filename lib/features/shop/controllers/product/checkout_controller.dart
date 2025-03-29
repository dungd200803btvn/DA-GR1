import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_my_app/common/widgets/texts/section_heading.dart';
import 'package:app_my_app/features/shop/models/payment_method_model.dart';
import 'package:app_my_app/features/shop/screens/checkout/widgets/payment_tile.dart';
import 'package:app_my_app/utils/constants/image_strings.dart';
import 'package:app_my_app/utils/constants/sizes.dart';

import '../../../../l10n/app_localizations.dart';

class CheckoutController extends GetxController{
  static CheckoutController get instance => Get.find();
  final Rx<PaymentMethodModel> selectedPaymentMethod = PaymentMethodModel.empty().obs;
  late AppLocalizations lang;
  @override
  void onInit() {
    selectedPaymentMethod.value = PaymentMethodModel(image: TImages.paypal, name: 'Paypal');
    super.onInit();
  }
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }

  Future<dynamic>  selectPaymentMethod(BuildContext buildContext){
    return showModalBottomSheet(context: buildContext,
        builder: (_)=> SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(DSize.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TSectionHeading(title: lang.translate('select_payment_method'),showActionButton: false,),
                SizedBox(height: DSize.spaceBtwSection,),
                TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Paypal',image: TImages.paypal)),
                SizedBox(height: DSize.spaceBtwItem/2,),
                TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Google Pay',image: TImages.googlePay)),
                SizedBox(height: DSize.spaceBtwItem/2,),
                TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Apple Pay',image: TImages.applePay)),
                SizedBox(height: DSize.spaceBtwItem/2,),
                TPaymentTile(paymentMethod: PaymentMethodModel(name: 'VISA',image: TImages.visa)),
                SizedBox(height: DSize.spaceBtwItem/2,),
                TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Master Card',image: TImages.masterCard)),
                SizedBox(height: DSize.spaceBtwItem/2,),
                TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Paytm',image: TImages.paytm)),
                SizedBox(height: DSize.spaceBtwItem/2,),
                TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Paystack',image: TImages.paystack)),
                SizedBox(height: DSize.spaceBtwItem/2,),
                TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Credit Card',image: TImages.creditCard)),
                SizedBox(height: DSize.spaceBtwItem/2,),
                SizedBox(height: DSize.spaceBtwSection,),
              ],
            ),
          ),

        ));
  }
}