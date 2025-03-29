import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:t_store_app/features/shop/controllers/product/cart_controller.dart';
import 'package:t_store_app/features/shop/screens/cart/cart.dart';
import 'package:t_store_app/l10n/app_localizations.dart';
import 'package:t_store_app/utils/formatter/formatter.dart';
import 'package:t_store_app/utils/helper/event_logger.dart';
import '../../../../../utils/popups/loader.dart';
import '../../../../review/screen/review_screen.dart';
import '../../../models/cart_item_model.dart';

class OrderItemCard extends StatelessWidget {
  final CartItemModel item;
  final DateTime deliveryDate;

  const OrderItemCard({
    super.key,
    required this.item,
    required this.deliveryDate,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DFormatter.FormattedDate(deliveryDate);
    final lang = AppLocalizations.of(context);
    final cartController = CartController.instance;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ngày giao hàng
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "${lang.translate('delivered')}: $formattedDate",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Thông tin sản phẩm
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh sản phẩm
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.image!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),

                // Thông tin chi tiết
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Hiển thị price và quantity trên cùng 1 dòng
                      Text(
                        "${lang.translate('one_product')}: ${DFormatter.formattedAmount(item.price)}VND",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "x ${lang.translate('quantity')}: ${item.quantity}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tổng giá (trên 1 dòng độc lập)
            Text(
              "${lang.translate('total')}: ${ DFormatter.formattedAmount(item.price * item.quantity)} VND",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Nút hành động: 2 button trên 1 dòng, căn chỉnh về bên phải
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Button "Mua lại" (repurchase)
                OutlinedButton(
                  onPressed: () async {
                    cartController.addOneToCart(item);
                    await EventLogger().logEvent(eventName: 'repurchase',
                    additionalData: {
                      'product_id':item.productId,
                      'product_quantity':item.quantity,
                      'product_variation':item.selectedVariation,
                      'product_price':item.price
                    });
                    TLoader.successSnackbar( title: lang.translate('add_to_cart'));
                    Get.to(()=> const CartScreen());
                    await EventLogger().logEvent(eventName: 'navigate_to_cart');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    lang.translate('repurchase'),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                // Button "Viết đánh giá" (write review)
                ElevatedButton(
                  onPressed: () async {
                    await EventLogger().logEvent(eventName: 'write_review',
                    additionalData: {
                      'product_id':item.productId
                    });
                    Get.to(()=> WriteReviewScreen(item: item,) );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    lang.translate('write_review'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
