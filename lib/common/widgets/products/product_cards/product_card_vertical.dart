import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/common/styles/shadows.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:t_store/common/widgets/images/t_rounded_image.dart';
import 'package:t_store/features/shop/controllers/product_controller.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/features/shop/screens/product_details/product_detail.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/enum/enum.dart';
import 'package:t_store/utils/helper/helper_function.dart';
import '../../icons/t_circular_icon.dart';
import '../../texts/product_price_text.dart';
import '../../texts/product_title_text.dart';
import '../../texts/t_branc_title_text_with_verified_icon.dart';
import '../favourite_icon/favourite_icon.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({super.key, required this.product});
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(product.price, product.salePrice);
    return GestureDetector(
      onTap: () => Get.to( ProductDetailScreen(product: product,)),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DSize.productImageRadius),
            color: dark ? DColor.darkerGrey : DColor.white,
            boxShadow: [TShadowStyle.verticalProductShadow]),
        child: Column(
          children: [
            //Thumbnail,wishlist,discount tag
            TRoundedContainer(
              height: 180,
              width: 180,
              padding: const EdgeInsets.all(DSize.sm),
              backgroundColor: dark ? DColor.light : DColor.light,
              child: Stack(
                children: [
                  //Thumbnail Image
                   Center(
                     child: TRoundedImage(
                        imageUrl: product.thumbnail, applyImageRadius: true, isNetWorkImage: true,),
                   ),
                  //Sale Tag
                  if(salePercentage!=null)
                  Positioned(
                    top: 12,
                    child: TRoundedContainer(
                      radius: DSize.sm,
                      backgroundColor: DColor.secondary.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: DSize.sm, vertical: DSize.xs),
                      child: Text('$salePercentage%',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .apply(color: DColor.black)),
                    ),
                  ),

                  ///Favourite Button
                   Positioned(
                      top: 0,
                      right: 0,
                      child: TFavouriteIcon(productId: product.id,)),
                ],
              ),
            ),
            const SizedBox(height: DSize.spaceBtwItem / 2),
            //Detail
             Padding(
              padding: EdgeInsets.only(left: DSize.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TProductTitleText(
                      title: product.title, smallSize: true),
                  SizedBox(height: DSize.spaceBtwItem / 2),
                  TBrandTitleWithVerifiedIcon(title: product.brand!=null ? product.brand!.name:" " ),
                ],
              ),
            ),
            const Spacer(),
            //Price Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Price
                Flexible(
                  child: Column(
                    children: [
                      if(product.productType==ProductType.single.toString() && product.salePrice> 0)
                        Padding(
                          padding: EdgeInsets.only(left: DSize.sm),
                          child: Text(
                            product.price.toString(),
                            style: Theme.of(context).textTheme.labelMedium!.apply(decoration: TextDecoration.lineThrough),
                          ),
                        ),

                      Padding(
                        padding: EdgeInsets.only(left: DSize.sm),
                        child: TProductPriceText(price: controller.getProductPrice(product)),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                      color: DColor.dark,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(DSize.cardRadiusMd),
                          bottomRight:
                          Radius.circular(DSize.productImageRadius))),
                  child: const SizedBox(
                      width: DSize.iconLg * 1.2,
                      height: DSize.iconLg * 1.2,
                      child: Center(
                          child: Icon(Iconsax.add, color: DColor.white))),
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
}




