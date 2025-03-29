import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:t_store_app/common/widgets/images/t_rounded_image.dart';
import 'package:t_store_app/common/widgets/products/favourite_icon/favourite_icon.dart';
import 'package:t_store_app/common/widgets/texts/product_price_text.dart';
import 'package:t_store_app/common/widgets/texts/product_title_text.dart';
import 'package:t_store_app/common/widgets/texts/t_branc_title_text_with_verified_icon.dart';
import 'package:t_store_app/features/shop/models/product_model.dart';
import 'package:t_store_app/utils/enum/enum.dart';
import 'package:t_store_app/utils/formatter/formatter.dart';

import '../../../../features/shop/controllers/product_controller.dart';
import '../../../../features/shop/screens/product_details/product_detail.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helper/event_logger.dart';
import '../../../../utils/helper/helper_function.dart';
import '../../../styles/shadows.dart';
import 'add_to_cart_button.dart';
class TProductCardHorizontal extends StatelessWidget {
  const TProductCardHorizontal({super.key, required this.product,this.salePercentage,});
final ProductModel product;
  final  double? salePercentage;
  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final dark = DHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: () async{
        await EventLogger().logEvent(eventName: 'navigate_to_product_detail',
            additionalData: {
              'product_id': product.id,
              'product_type': product.productType,
            });
        Get.to( ProductDetailScreen(product: product,salePercentage: salePercentage,));
      } ,
      child: Container(
        width: 310,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DSize.productImageRadius),
            color: dark ? DColor.darkerGrey : DColor.softGrey,
            boxShadow: [TShadowStyle.verticalProductShadow]),
        child: Row(
          children: [
            //Thumbnail
            TRoundedContainer(
              height: 120,
              padding: const EdgeInsets.all(DSize.sm),
              backgroundColor: dark? DColor.dark:DColor.light,
              child: Stack(
                children: [
                   SizedBox(
                      height: 120,
                  width: 120,
                      child: TRoundedImage(imageUrl: product.images![0],applyImageRadius: true,isNetWorkImage: true,),),
                  //Sale Tag
                  if(salePercentage!=null)
                  Positioned(
                    top: 12,
                    child: TRoundedContainer(
                      radius: DSize.sm,
                      backgroundColor: DColor.secondary.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: DSize.sm, vertical: DSize.xs),
                      child: Text('${controller.calculateSalePercentage(salePercentage)}%',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .apply(color: DColor.black)),
                    ),
                  ),
                  //Favourite Button
                 Positioned(
                      top: 0,
                      right: 0,
                      child: TFavouriteIcon(productId: product.id ,)),
                ],
              ),
            ),
            const SizedBox(width: DSize.spaceBtwItem/2,),

            //Detail
            Expanded(
              child: SizedBox(
                width: 172,
                child: Padding(
                  padding: const EdgeInsets.only(top: DSize.sm,left: DSize.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TProductTitleText(title: product.title,smallSize: true,),
                          const SizedBox(height: DSize.spaceBtwItem/2,),
                          TBrandTitleWithVerifiedIcon(title: product.brand!.name)
                        ],
                      ),
                      const Spacer(),

                      Row(

                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Pricing
                           Flexible(child: Column(
                             children: [
                               if(product.productType == ProductType.single.toString() && salePercentage!=null)
                                 Padding(padding: const EdgeInsets.only(left: DSize.sm),
                                 child: Text(
                                   DFormatter.formattedAmount(product.price) ,
                                   style: Theme.of(context).textTheme.labelMedium!.apply(decoration: TextDecoration.lineThrough),
                                 ),
                                 ),
                               Padding(padding: const EdgeInsets.only(left: DSize.sm),child: TProductPriceText(price: controller.getProductPrice(product),),)
                             ],
                           )),
                          ProductCardAddtoCartButton(product: product,salePercentage: salePercentage,)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
