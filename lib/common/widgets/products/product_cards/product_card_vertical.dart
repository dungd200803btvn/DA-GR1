import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:app_my_app/common/styles/shadows.dart';
import 'package:app_my_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:app_my_app/common/widgets/images/t_rounded_image.dart';
import 'package:app_my_app/features/shop/controllers/product_controller.dart';
import 'package:app_my_app/features/shop/models/product_model.dart';
import 'package:app_my_app/features/shop/screens/product_details/product_detail.dart';
import 'package:app_my_app/utils/constants/colors.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/enum/enum.dart';
import 'package:app_my_app/utils/helper/event_logger.dart';
import 'package:app_my_app/utils/helper/helper_function.dart';
import '../../../../utils/formatter/formatter.dart';
import '../../texts/product_price_text.dart';
import '../../texts/product_title_text.dart';
import '../../texts/t_branc_title_text_with_verified_icon.dart';
import '../favourite_icon/favourite_icon.dart';
import 'add_to_cart_button.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({
    super.key,
    required this.product,
    this.salePercentage,
  });

  final ProductModel product;
  final double? salePercentage;

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final imageUrl;
    final isNetWorkImage;
    if (product.images != null && product.images!.isNotEmpty) {
      imageUrl = product.images![0];
      isNetWorkImage = true;
    } else {
      imageUrl = 'assets/images/bonus_point.jpg';
      isNetWorkImage = false;
    }

    return GestureDetector(
      onTap: () async {
        await EventLogger()
            .logEvent(eventName: 'navigate_to_product_detail', additionalData: {
          'product_id': product.id,
          'product_type': product.productType,
        });
        Get.to(ProductDetailScreen(
          product: product,
          salePercentage: salePercentage,
        ));
      },
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
                      imageUrl: imageUrl,
                      applyImageRadius: true,
                      isNetWorkImage: isNetWorkImage,
                    ),
                  ),
                  //Sale Tag
                  if (salePercentage != null)
                    Positioned(
                      top: 12,
                      child: TRoundedContainer(
                        radius: DSize.sm,
                        backgroundColor: DColor.secondary.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: DSize.sm, vertical: DSize.xs),
                        child: Text(
                            '${controller.calculateSalePercentage(salePercentage)}%',
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
                      child: TFavouriteIcon(
                        productId: product.id,
                      )),
                ],
              ),
            ),
            const SizedBox(height: DSize.spaceBtwItem / 2),
            //Detail
            Padding(
              padding: const EdgeInsets.only(left: DSize.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TProductTitleText(title: product.title, smallSize: true),
                  const SizedBox(height: DSize.spaceBtwItem / 4),
                  TBrandTitleWithVerifiedIcon(
                      title: product.brand != null ? product.brand!.name : " "),
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
                      if (product.productType ==
                              ProductType.single.toString() &&
                          salePercentage != null)
                        //gia cu bi gach di
                        Padding(
                          padding: const EdgeInsets.only(left: DSize.sm),
                          child: Text(
                            DFormatter.formattedAmount(product.price),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .apply(decoration: TextDecoration.lineThrough),
                          ),
                        ),
                      //Gia moi sau khi ap dung chinh sach khuyen mai
                      Padding(
                        padding: const EdgeInsets.only(left: DSize.sm),
                        child: TProductPriceText(
                            price: controller.getProductPrice(
                                product, salePercentage)),
                      ),
                    ],
                  ),
                ),
                ProductCardAddtoCartButton(
                  product: product,
                  salePercentage: salePercentage,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
