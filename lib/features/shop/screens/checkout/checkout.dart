import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:t_store/features/shop/controllers/product/cart_controller.dart';
import 'package:t_store/features/shop/controllers/product/order_controller.dart';
import 'package:t_store/features/shop/screens/checkout/widgets/billing_address_section.dart';
import 'package:t_store/features/shop/screens/checkout/widgets/billing_amount_section.dart';
import 'package:t_store/features/shop/screens/checkout/widgets/billing_payment_section.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helper/helper_function.dart';
import 'package:t_store/utils/popups/loader.dart';
import '../../../../common/widgets/products/cart/coupon_widget.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/formatter/formatter.dart';
import '../cart/widgets/cart_items.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final cartController = CartController.instance;
    final orderController = OrderController.instance;
    final subTotal = cartController.totalCartPrice.value;
    final lang = AppLocalizations.of(context);
    // Gọi hàm processOrder ngay khi màn hình được build
    Future.delayed(Duration.zero, () {
    if (subTotal > 0) {
    orderController.calculateFeeAndTotal(subTotal);
    }
    });
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          lang.translate('order_review'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Column(
              //Items in the cart
              children: [
                 const TCartItems(
                   showAddRemoveButtons: false,
                   scrollable: false,
                ),
                const SizedBox(
                  height: DSize.spaceBtwSection,
                ),
                //Coupon TextField
                Obx(()=> TCouponCode(totalValue: orderController.totalAmount.value*24500, userId: AuthenticationRepository.instance.authUser!.uid ,)),
                const SizedBox(
                  height: DSize.spaceBtwSection,
                ),
        
                //Billing Section
                TRoundedContainer(
                  showBorder: true,
                  backgroundColor: dark?DColor.black:DColor.white,
                  padding: const EdgeInsets.all(DSize.defaultspace),
                  child: const Column(
                    children: [
                      //Pricing
                      TBillingAmountSection(),
                      SizedBox(height: DSize.spaceBtwItem,),
                      //Divider
                      Divider(),
                      SizedBox(height: DSize.spaceBtwItem,),
                      //Payment Method
                      TBillingPaymentSection(),
                      SizedBox(height: DSize.spaceBtwItem,),
                      //Address
                      TBillingAddressSection(),
                      SizedBox(height: DSize.spaceBtwItem,),
                    ],
                  ),
                )
        
              ]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(DSize.defaultspace),
        child: ElevatedButton (
          onPressed: subTotal> 0 ? ()=> orderController.processOrder(subTotal,context)
          : () => TLoader.warningSnackbar(title: lang.translate('empty_cart'),message: lang.translate('add_cart_warning')),
          child: Obx(() => Text('${lang.translate('checkout')}: ${DFormatter.formattedAmount(orderController.netAmount.value*24500)} VND')),
        ),
      ),

    );
  }
}
