import 'package:flutter/material.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helper/helper_function.dart';

class TCircularIcon extends StatelessWidget {
  const TCircularIcon({
    super.key,
    this.width,
    this.height,
    this.size = DSize.lg,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.onPressed,
  });

final double? width,height,size;
final IconData icon;
final Color?  color;
final Color?  backgroundColor;
final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: backgroundColor!=null? backgroundColor! :  dark? DColor.light: DColor.light ,
      ),
      child: IconButton(onPressed: onPressed,icon: Icon(icon,color: color,size: size)),
    );
  }
}

