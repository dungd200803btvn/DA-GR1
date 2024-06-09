import 'package:flutter/material.dart';
import 'package:t_store/features/shop/models/brand_model.dart';
import 'package:t_store/utils/helper/helper_function.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../custom_shapes/containers/rounded_container.dart';
import '../images/t_circular_image.dart';
import '../texts/t_branc_title_text_with_verified_icon.dart';

class TBrandCard extends StatelessWidget {
  const TBrandCard({
    super.key,
    required this.showBorder,
    this.onTap, required this.brand,
  });
  final BrandModel brand;
  final bool showBorder;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: TRoundedContainer(
        padding: const EdgeInsets.all(DSize.sm),
        showBorder: showBorder,
        backgroundColor: Colors.transparent,
        child: Row(
          children: [
            //Icon
            Flexible(
              child: TCircularImage(
                  image: brand.image,
                  isNetworkImage: true,
                  backgroundColor: Colors.transparent,
                  overlayColor: dark ? DColor.white : DColor.black),
            ),
            const SizedBox(width: DSize.spaceBtwItem / 2),
            //Text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TBrandTitleWithVerifiedIcon(
                      title: brand.name, branchTextSize: TTextSize.largre),
                  Text('${brand.productsCount?? 0} products',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
