import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:lcd_ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:lcd_ecommerce_app/features/shop/controllers/product/checkout_controller.dart';
import 'package:lcd_ecommerce_app/utils/constants/colors.dart';
import 'package:lcd_ecommerce_app/utils/constants/image_strings.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/helper/helper_function.dart';
class TBillingPaymentSection extends StatelessWidget {
  const TBillingPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = CheckoutController.instance;
    final lang = AppLocalizations.of(context);
    return Column(
      children: [
        TSectionHeading(title: lang.translate('payment_method'),buttonTitle: lang.translate('change'),onPressed: ()=> controller.selectPaymentMethod(context),),
        const SizedBox(height: DSize.spaceBtwItem/2,),
        Obx(
          ()=> Row(
            children: [
              TRoundedContainer(
                width: 60,
                height: 35,
                backgroundColor: dark? DColor.light:DColor.white,
                padding: const EdgeInsets.all(DSize.sm),
                child:  Image(image: AssetImage(controller.selectedPaymentMethod.value.image),fit: BoxFit.contain,),
              ),
              const SizedBox(width: DSize.spaceBtwItem/2,),
              Text(controller.selectedPaymentMethod.value.name,style: Theme.of(context).textTheme.bodyLarge,)
            ],
          ),
        )
      ],
    );
  }
}
