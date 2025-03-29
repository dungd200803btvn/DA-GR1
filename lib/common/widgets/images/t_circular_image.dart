import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_app/common/widgets/shimmer/shimmer.dart';
import 'package:my_app/utils/helper/helper_function.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class TCircularImage extends StatelessWidget {
  const TCircularImage({
    super.key,
    this.fit = BoxFit.cover,
    required this.image,
    this.isNetworkImage = false,
    this.overlayColor,
    this.backgroundColor,
    this.width = 56,
    this.height = 56,
    this.padding = DSize.sm,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor, backgroundColor;
  final double width, height, padding;

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(width),
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor ?? (dark ? DColor.black : DColor.white),
          borderRadius: BorderRadius.circular(width),
        ),
        child: isNetworkImage
            ? CachedNetworkImage(
          imageUrl: image,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          color: overlayColor,

        )
            : Image(
          fit: BoxFit.cover,
          image: AssetImage(image),
          color: overlayColor,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
