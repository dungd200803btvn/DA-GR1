import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/common/widgets/icons/t_circular_icon.dart';
import 'package:t_store/features/shop/controllers/product/cart_controller.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helper/helper_function.dart';

import '../../../../../l10n/app_localizations.dart';
class TBottomAddToCart extends StatelessWidget {
  const TBottomAddToCart({super.key, required this.product,this.salePercentage});
final ProductModel product;
final double? salePercentage;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = CartController.instance;
    final lang = AppLocalizations.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateAlreadyAddedProductCount(product);
    });
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSize.defaultspace,vertical: DSize.defaultspace/2),
      decoration: BoxDecoration(
        color: dark? DColor.darkerGrey:DColor.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DSize.cardRadiusLg),
          topRight: Radius.circular(DSize.cardRadiusLg)
        )
      ),
      child: Obx(
        ()=> Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              ()=> Row(
                children: [
                  TCircularIcon(icon: Iconsax.minus,
                    backgroundColor: DColor.darkGrey,
                    width: 40,
                    height: 40,
                    color: DColor.white,
                    onPressed: ()=> controller.productQuantityInCart.value <1 ? null: controller.productQuantityInCart.value-=1,
                  ),
                  const SizedBox(width: DSize.spaceBtwItem),
                  Text(controller.productQuantityInCart.value.toString(),style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(width: DSize.spaceBtwItem,),
                   TCircularIcon(icon: Iconsax.add,
                    backgroundColor: DColor.black,
                    width: 40,
                    height: 40,
                    color: DColor.white,
                     onPressed: ()=> controller.productQuantityInCart.value+=1 ,
                  ),
                ],

              ),
            ),
            ElevatedButton(onPressed: controller.productQuantityInCart.value<1 ? null: () => controller.addToCart(product,salePercentage),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(DSize.md),
              backgroundColor: DColor.black,
              side: const BorderSide(color: DColor.black)
            ), child:  Text(lang.translate('add_cart')),),
          ],
        ),
      ),
    );
  }
}
