import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store_app/features/shop/controllers/product_controller.dart';
import 'package:t_store_app/utils/helper/event_logger.dart';
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
                                add: () async{
                                  controller.addOneToCart(item);
                                  await EventLogger().logEvent(eventName: 'add_one_in_cart',
                                      additionalData:{
                                    'product_id': item.productId
                                      } );
            }  ,
                                remove: () async{
                                  controller.removeOneFromCart(item);
                                  await EventLogger().logEvent(eventName: 'remove_one_in_cart',
                                      additionalData:{
                                        'product_id': item.productId
                                      } );
            }
                                   ,
                              ),
                              // Button: See suggested products
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 180),
                                child: TextButton(
                                  onPressed: () async{
                                    Get.to(
                                          () => AllProducts(
                                        title: lang.translate('suggest_promotional_products'),
                                        query: FirebaseFirestore.instance
                                            .collection('Products')
                                            .where('IsFeatured', isEqualTo: true)
                                            .limit(20),
                                        futureMethod: productController.getSuggestedProductsById(item.productId),
                                        applyDiscount: true,
                                      ),
                                    );
                                    await EventLogger().logEvent(eventName: 'see_suggest_product',
                                    additionalData: {
                                      'product_id': item.productId
                                    });
            } ,
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
                              price: DFormatter.formattedAmount(item.price * item.quantity) ,
                            ),
                          ),
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
