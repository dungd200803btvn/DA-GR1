import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_app/features/shop/controllers/product/cart_controller.dart';
import 'package:my_app/features/shop/screens/cart/cart.dart';
import 'package:my_app/utils/helper/event_logger.dart';
import 'package:my_app/utils/helper/helper_function.dart';
import '../../../../utils/constants/colors.dart';
class TCartCounterIcon extends StatelessWidget {
  const TCartCounterIcon({
    super.key,
     this.iconColor, this.counterBgColor, this.counterTextColor,
  });
  final Color? iconColor,counterBgColor,counterTextColor;
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    final dark = DHelperFunctions.isDarkMode(context);
    return Stack(
      children: [
        IconButton(
          onPressed: () async{
            await EventLogger().logEvent(eventName: 'navigate_to_cart');
            Get.to(()=> const CartScreen());
    } ,
            icon: Icon(
              Iconsax.shopping_cart,
              color: iconColor?? (dark? DColor.white: DColor.black),
            )),
        Positioned(
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Center(
              child: Obx(
            ()=>Text(
                  controller.numOfCartItems.value.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .apply(color: counterTextColor?? (dark? DColor.white: DColor.black), fontSizeFactor: 0.8),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
