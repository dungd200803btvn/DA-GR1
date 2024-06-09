import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/brands/t_brand_cart.dart';
import 'package:t_store/common/widgets/shimmer/shimmer.dart';
import 'package:t_store/features/shop/models/brand_model.dart';
import 'package:t_store/features/shop/screens/brand/brand_products.dart';
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
      onTap: ()=> Get.to(()=> BrandProducts(brand: brand)),
      child: TRoundedContainer(
        showBorder: true,
        borderColor: DColor.darkGrey,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: DSize.spaceBtwItem),
        padding: const EdgeInsets.all(DSize.md),
        child: Column(
          children: [
            //Brand with product count
             TBrandCard(showBorder: false, brand: brand,),
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
        progressIndicatorBuilder: (context,url,downloadProgress)=> TShimmerEffect(width: 100, height: 100),
        errorWidget: (context,url,error)=> Icon(Icons.error),),
      ),
    );
  }
}
