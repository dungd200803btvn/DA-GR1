import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/common/widgets/loaders/animation_loader.dart';
import 'package:t_store/features/shop/controllers/product/cart_controller.dart';
import 'package:t_store/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:t_store/features/shop/screens/checkout/checkout.dart';
import 'package:t_store/navigation_menu.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/constants/sizes.dart';
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
                onPressed: () => Get.to(() => const CheckoutScreen()),
                child: Obx(() =>
                    Text('${lang.translate('checkout')} ${DFormatter.formattedAmount(controller.totalCartPrice.value*24500)} VND')),
              ),
            ),
    );
  }
}
