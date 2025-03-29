import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store_app/utils/constants/colors.dart';
import 'package:t_store_app/utils/constants/sizes.dart';
import 'package:t_store_app/utils/device/device_utility.dart';
import 'package:t_store_app/utils/helper/helper_function.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar(
      {super.key,
      this.title,
       this.showBackArrow =false,
      this.leadingIcon,
      this.actions,
      this.leadingOnPressed});
  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    return Padding(
      padding:  const EdgeInsets.symmetric(
        horizontal: DSize.md,
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(
                onPressed: leadingOnPressed ?? () => Get.back(),
                icon: Icon(Iconsax.arrow_left,  color: dark? DColor.white:DColor.dark),
              )
            : leadingIcon != null
                ? IconButton(
                    onPressed: leadingOnPressed,
                    icon: Icon(leadingIcon),
                  )
                : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
