import 'package:flutter/material.dart';
import 'package:lcd_ecommerce_app/utils/constants/colors.dart';
import 'package:lcd_ecommerce_app/utils/device/device_utility.dart';
import 'package:lcd_ecommerce_app/utils/helper/helper_function.dart';
class TTabBar extends StatelessWidget implements PreferredSizeWidget {
  const TTabBar({super.key, required this.tabs});
final List<Widget> tabs;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    return Material(
      color: dark? Colors.black: DColor.white,
      child: TabBar(
        tabs: tabs,
        isScrollable: true,
        indicatorColor: DColor.primary,
        labelColor: dark? DColor.white:DColor.primary,
        unselectedLabelColor: DColor.darkGrey,
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
