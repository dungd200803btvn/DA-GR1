import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../../utils/helper/helper_function.dart';
class TSearchContainer extends StatelessWidget {
  const TSearchContainer({
    super.key,
    required this.text,
    this.icon= Iconsax.search_normal,
    this.showBackground=true,
    this.showBorder=true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: DSize.defaultspace),
  });
  final String text;
  final IconData? icon;
  final bool showBackground,showBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Container(
          width: TDeviceUtils.getScreenWidth(context),
          padding: const EdgeInsets.all(DSize.md),
          decoration: BoxDecoration(
            color: showBackground? dark? DColor.dark:   DColor.light: Colors.transparent,
            borderRadius: BorderRadius.circular(DSize.cardRadiusLg),
            border: showBorder?    Border.all(color: dark? DColor.dark:   DColor.grey):null,
          ),
          child: Row(
            children: [
              Icon(icon,color: DColor.grey,),
              const SizedBox(width: DSize.spaceBtwItem,),
              Text(text,style: Theme.of(context).textTheme.bodySmall,)
            ],
          ),
        ),
      ),
    );
  }
}