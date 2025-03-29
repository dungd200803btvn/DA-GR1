import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store_app/common/widgets/brands/t_brand_cart.dart';
import 'package:t_store_app/common/widgets/shimmer/shimmer.dart';
import 'package:t_store_app/features/shop/models/brand_model.dart';
import 'package:t_store_app/features/shop/screens/brand/brand_products.dart';
import 'package:t_store_app/utils/helper/event_logger.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helper/helper_function.dart';
import '../custom_shapes/containers/rounded_container.dart';

class TBrandShowCase extends StatelessWidget {
  const TBrandShowCase({
    super.key,
    required this.images, required this.brand,
  });
  final BrandModel brand;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async{
        await EventLogger().logEvent(eventName: 'view_product_of_brand',
        additionalData: {
          'brand_name':brand.name
        });
        Get.to(()=> BrandProducts(brand: brand));
      } ,
      child: TRoundedContainer(
        showBorder: true,
        borderColor: DColor.darkGrey,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: DSize.spaceBtwItem),
        padding: const EdgeInsets.all(DSize.md),
        child: Column(
          children: [
            //Brand with product count
             TBrandCard(showBorder: true, brand: brand,),
            const SizedBox(height: DSize.spaceBtwItem),
            //Brand top 3 product image
            Row(
              children: images
                  .map((e) => branchTopProductImageWidget(e, context))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget branchTopProductImageWidget(String image, BuildContext context) {
    return Expanded(
      child: TRoundedContainer(
        height: 100,
        backgroundColor: DHelperFunctions.isDarkMode(context)
            ? DColor.darkerGrey
            : DColor.light,
        margin: const EdgeInsets.only(right: DSize.sm),
        padding: const EdgeInsets.all(DSize.md),
        child: CachedNetworkImage(fit: BoxFit.contain, imageUrl: image,
        progressIndicatorBuilder: (context,url,downloadProgress)=> const TShimmerEffect(width: 100, height: 100),
        errorWidget: (context,url,error)=> const Icon(Icons.error),),
      ),
    );
  }
}
