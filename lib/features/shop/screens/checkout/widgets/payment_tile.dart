import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:t_store_app/features/shop/controllers/product/checkout_controller.dart';
import 'package:t_store_app/features/shop/models/payment_method_model.dart';
import 'package:t_store_app/utils/constants/colors.dart';
import 'package:t_store_app/utils/constants/sizes.dart';
import 'package:t_store_app/utils/helper/helper_function.dart';
class TPaymentTile extends StatelessWidget {
  const TPaymentTile({super.key, required this.paymentMethod});
  final PaymentMethodModel paymentMethod;
  @override
  Widget build(BuildContext context) {
    final controller = CheckoutController.instance;
    final dark = DHelperFunctions.isDarkMode(context);
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      onTap: (){
        controller.selectedPaymentMethod.value = paymentMethod;
        Get.back();
      },
      leading: TRoundedContainer(
        width: 60,
        height: 40,
        backgroundColor: dark? DColor.light: DColor.white,
        padding: EdgeInsets.all(DSize.sm),
        child: Image(image: AssetImage(paymentMethod.image),fit: BoxFit.contain,),
      ),
      title: Text(paymentMethod.name),
      trailing: Icon(Iconsax.arrow_right_34),
    );
  }
}
