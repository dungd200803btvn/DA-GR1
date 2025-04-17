import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_my_app/features/shop/controllers/product_controller.dart';
import 'package:app_my_app/utils/helper/event_logger.dart';
import '../../../../../common/widgets/products/cart/add_remove_button.dart';
import '../../../../../common/widgets/products/cart/cart_item.dart';
import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatter/formatter.dart';
import '../../../../../utils/singleton/user_singleton.dart';
import '../../../../suggestion/service/RecommendationService.dart';
import '../../../controllers/product/cart_controller.dart';
import '../../all_products/all_products.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({
    super.key,
    this.showAddRemoveButtons = true,
    this.scrollable = true,
  });

  final bool showAddRemoveButtons;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dòng: Add/Remove + Giá
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  TProductQuantityWithAddRemoveButton(
                                    quantity: item.quantity,
                                    add: () async {
                                      controller.addOneToCart(item);
                                      await EventLogger().logEvent(
                                        eventName: 'add_one_in_cart',
                                        additionalData: {'product_id': item.productId},
                                      );
                                    },
                                    remove: () async {
                                      controller.removeOneFromCart(item);
                                      await EventLogger().logEvent(
                                        eventName: 'remove_one_in_cart',
                                        additionalData: {'product_id': item.productId},
                                      );
                                    },
                                  ),
                                ],
                              ),
                              // Giá tiền
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: DFormatter.formattedAmount(item.price * item.quantity),
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const TextSpan(
                                      text: ' VND',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Dòng: Gợi ý sản phẩm
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  Get.to(
                                        () => AllProducts(
                                      title: lang.translate('suggest_promotional_products'),
                                      futureMethod: RecommendationService.instance
                                          .getRecommendedProducts(
                                          userId: UserSession.instance.userId!,
                                          productId: item.productId),
                                      applyDiscount: true,
                                    ),
                                  );
                                  await EventLogger().logEvent(
                                    eventName: 'see_suggest_product',
                                    additionalData: {'product_id': item.productId},
                                  );
                                },
                                icon: const Icon(Icons.recommend, size: 18),
                                label: Text(
                                  lang.translate('suggest_products'),
                                  style: const TextStyle(fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

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
