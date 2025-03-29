import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store_app/common/widgets/appbar/appbar.dart';
import 'package:t_store_app/common/widgets/loaders/animation_loader.dart';
import 'package:t_store_app/features/shop/controllers/product/cart_controller.dart';
import 'package:t_store_app/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:t_store_app/features/shop/screens/checkout/checkout.dart';
import 'package:t_store_app/navigation_menu.dart';
import 'package:t_store_app/utils/constants/image_strings.dart';
import 'package:t_store_app/utils/constants/sizes.dart';
import 'package:t_store_app/utils/helper/event_logger.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/formatter/formatter.dart';
import '../../controllers/product/order_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    Get.put(OrderController());
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('cart'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Obx(() {
        //nothing found widget
        final emptyWidget = TAnimationLoaderWidget(
          text: lang.translate('cart_empty'),
          animation: TImages.cartAnimation,
          showAction: true,
          actionText: lang.translate('fill_cart'),
          onActionPressed: (){
            Get.offAll(const NavigationMenu());
          }
        );
        if (controller.cartItems.isEmpty) {
          return emptyWidget;
        } else {
          return const Padding(
            padding: EdgeInsets.all(DSize.defaultspace),
            child: TCartItems(),
          );
        }
      }),
      bottomNavigationBar: controller.cartItems.isEmpty
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.all(DSize.defaultspace),
              child: ElevatedButton(
                onPressed: () async{
                  Get.to(() => const CheckoutScreen());
                  await EventLogger().logEvent(eventName: 'navigate_to_checkout',);
                }  ,
                child: Obx(() =>
                    Text('${lang.translate('checkout')} ${DFormatter.formattedAmount(controller.totalCartPrice.value)} VND')),
              ),
            ),
    );
  }
}
