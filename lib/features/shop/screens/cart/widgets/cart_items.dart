import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/features/shop/controllers/product_controller.dart';
import '../../../../../common/widgets/products/cart/add_remove_button.dart';
import '../../../../../common/widgets/products/cart/cart_item.dart';
import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatter/formatter.dart';
import '../../../controllers/product/cart_controller.dart';
import '../../all_products/all_products.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({super.key, this.showAddRemoveButtons = true, this.scrollable = true,});
  final bool showAddRemoveButtons;
  final bool scrollable;
  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    final productController = ProductController.instance;
    final lang = AppLocalizations.of(context);
    return Obx(
      () => ListView.separated(
          physics: scrollable ? null : const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (_, index) => Obx(() {
                final item = controller.cartItems[index];
                return Column(
                  children: [
                    TCartItem(
                      cartItem: item,
                    ),
                    if (showAddRemoveButtons)
                      const SizedBox(
                        height: DSize.spaceBtwItem,
                      ),
                    if (showAddRemoveButtons)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              //Can le trai
                              const SizedBox(
                                width: 10,
                              ),
                              //Add and remove button
                              TProductQuantityWithAddRemoveButton(
                                quantity: item.quantity,
                                add: () => controller.addOneToCart(item),
                                remove: () =>
                                    controller.removeOneFromCart(item),
                              ),
                              // Button: See suggested products
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 180),
                                child: TextButton(
                                  onPressed: () => Get.to(
                                        () => AllProducts(
                                      title: lang.translate('suggest_promotional_products'),
                                      query: FirebaseFirestore.instance
                                          .collection('Products')
                                          .where('IsFeatured', isEqualTo: true)
                                          .limit(20),
                                      futureMethod: productController.getSuggestedProductsById(item.productId),
                                          applyDiscount: true,
                                    ),
                                  ),
                                  child:  Text(lang.translate('suggest_products'),
                                  overflow: TextOverflow.ellipsis,
                                    selectionColor: Colors.white,

                                  ),
                                ),
                              ),
                            ],
                          ),
                          //Product total price
                          Expanded(
                            child: TProductPriceText(
                              price: DFormatter.formattedAmount(item.price * item.quantity*24500) ,
                            ),
                          ),
                           // TProductPriceText(price: (item.price * item.quantity).toStringAsFixed(1)),
                        ],
                      )
                  ],
                );
              }),
          separatorBuilder: (_, __) => const SizedBox(
                height: DSize.spaceBtwSection,
              ),
          itemCount: controller.cartItems.length),
    );
  }
}
