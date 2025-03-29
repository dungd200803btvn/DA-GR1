import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:app_my_app/common/widgets/icons/t_circular_icon.dart';
import 'package:app_my_app/features/shop/controllers/product/cart_controller.dart';
import 'package:app_my_app/features/shop/controllers/product/variation_controller.dart';
import 'package:app_my_app/features/shop/models/product_model.dart';
import 'package:app_my_app/utils/constants/colors.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/enum/enum.dart';
import 'package:app_my_app/utils/helper/helper_function.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/helper/event_logger.dart';
class TBottomAddToCart extends StatelessWidget {
  const TBottomAddToCart({super.key, required this.product,this.salePercentage});
final ProductModel product;
final double? salePercentage;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = CartController.instance;
    final variationController = VariationController.instance;
    final lang = AppLocalizations.of(context);
    final isSingle = product.productType ==ProductType.single;
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
      child: Row(
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
                  onPressed: () async{
                    controller.productQuantityInCart.value <1 ? null: controller.productQuantityInCart.value-=1;
                    // Log event giảm số lượng
                    isSingle?
                    await EventLogger().logEvent(
                      eventName: "decrease_quantity",
                      additionalData: {
                        'product_id': product.id,
                        'new_quantity': controller.productQuantityInCart.value,
                      },
                    ) :  await EventLogger().logEvent(
                      eventName: "decrease_quantity",
                      additionalData: {
                        'product_id': product.id,
                        'new_quantity': controller.productQuantityInCart.value,
                        "selectedVariationId": variationController.selectedVariation.value.id,
                      },
                    );
                  },
                ),
                const SizedBox(width: DSize.spaceBtwItem),
                Text(controller.productQuantityInCart.value.toString(),style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: DSize.spaceBtwItem,),
                TCircularIcon(icon: Iconsax.add,
                  backgroundColor: DColor.black,
                  width: 40,
                  height: 40,
                  color: DColor.white,
                  onPressed: () async{
                    controller.productQuantityInCart.value+=1;
                    // Log event tăng số lượng
                    isSingle?
                    await EventLogger().logEvent(
                      eventName: "increase_quantity",
                      additionalData: {
                        'product_id': product.id,
                        'new_quantity': controller.productQuantityInCart.value,
                      },
                    ): await EventLogger().logEvent(
                      eventName: "increase_quantity",
                      additionalData: {
                        'product_id': product.id,
                        'new_quantity': controller.productQuantityInCart.value,
                        "selectedVariationId": variationController.selectedVariation.value.id,
                      },
                    );
                  }  ,
                ),
              ],

            ),
          ),
          ElevatedButton(onPressed:  () async{
            controller.addToCart(product,salePercentage);
            isSingle?
            await EventLogger().logEvent(
              eventName: "add_to_cart",
              additionalData: {
                'product_id': product.id,
                'quantity_added': controller.productQuantityInCart.value,
              },
            ) : await EventLogger().logEvent(
              eventName: "add_to_cart",
              additionalData: {
                'product_id': product.id,
                'quantity_added': controller.productQuantityInCart.value,
                "selectedVariationId": variationController.selectedVariation.value.id,
              },
            ) ;
          },
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(DSize.md),
                backgroundColor: DColor.black,
                side: const BorderSide(color: DColor.black)
            ), child:  Text(lang.translate('add_cart')),),
        ],
      ),
    );
  }
}
