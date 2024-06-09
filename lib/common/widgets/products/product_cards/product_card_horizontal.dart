import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:t_store/common/widgets/images/t_rounded_image.dart';
import 'package:t_store/common/widgets/products/favourite_icon/favourite_icon.dart';
import 'package:t_store/common/widgets/texts/product_price_text.dart';
import 'package:t_store/common/widgets/texts/product_title_text.dart';
import 'package:t_store/common/widgets/texts/t_branc_title_text_with_verified_icon.dart';
import 'package:t_store/utils/constants/image_strings.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helper/helper_function.dart';
import '../../../styles/shadows.dart';
import '../../icons/t_circular_icon.dart';
class TProductCardHorizontal extends StatelessWidget {
  const TProductCardHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    return Container(
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
                const SizedBox(
                    height: 120,
                width: 120,
                    child: TRoundedImage(imageUrl: TImages.productImage1,applyImageRadius: true,),),
                //Sale Tag
                Positioned(
                  top: 12,
                  child: TRoundedContainer(
                    radius: DSize.sm,
                    backgroundColor: DColor.secondary.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: DSize.sm, vertical: DSize.xs),
                    child: Text('25%',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .apply(color: DColor.black)),
                  ),
                ),
                //Favourite Button
                const Positioned(
                    top: 0,
                    right: 0,
                    child: TFavouriteIcon(productId: '',)),
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
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TProductTitleText(title: 'Green Nike Half Sleeves Shirt',smallSize: true,),
                        SizedBox(height: DSize.spaceBtwItem/2,),
                        TBrandTitleWithVerifiedIcon(title: 'Nike')
                      ],
                    ),
            
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Pricing
                        const Flexible(child: TProductPriceText(price: '35.0affsafsafa')),
                        //Add to cart
                          Container(
                            decoration: const BoxDecoration(
                              color: DColor.dark,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(DSize.cardRadiusMd),
                                bottomRight: Radius.circular(DSize.productImageRadius)
                              )
                            ),
                            child: const SizedBox(
                              width: DSize.iconLg*1.2,
                              height: DSize.iconLg*1.2,
                              child: Center(child: Icon(Iconsax.add,color: DColor.white,),),
                            ),
                          )
                      ],
                    )
            
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

