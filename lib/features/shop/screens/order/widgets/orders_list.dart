import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/common/widgets/loaders/animation_loader.dart';
import 'package:lcd_ecommerce_app/features/shop/controllers/product/order_controller.dart';
import 'package:lcd_ecommerce_app/l10n/app_localizations.dart';
import 'package:lcd_ecommerce_app/navigation_menu.dart';
import 'package:lcd_ecommerce_app/utils/constants/image_strings.dart';
import 'package:lcd_ecommerce_app/utils/formatter/formatter.dart';
import 'package:lcd_ecommerce_app/utils/helper/cloud_helper_functions.dart';
import '../../../../../utils/helper/helper_function.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/order_model.dart';
import 'order_item_card.dart';

// Đây là ví dụ widget TOrderListItems
class TOrderListItems extends StatelessWidget {
  const TOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = Get.put(OrderController());
    final lang = AppLocalizations.of(context);

    return FutureBuilder<List<OrderModel>>(
      future: controller.fetchUserOrders(),
      builder: (_, snapshot) {
        // Xử lý widget nếu không có đơn hàng hoặc bị lỗi
        final emptyWidget = TAnimationLoaderWidget(
          text: lang.translate('no_order'),
          animation: TImages.orderCompletedAnimation,
          showAction: true,
          actionText: lang.translate('let_fill_it'),
          onActionPressed: () => Get.off(() => const NavigationMenu()),
        );

        // Kiểm tra trạng thái fetch
        final response = TCloudHelperFunctions.checkMultiRecordState(
          snapshot: snapshot,
          nothingFound: emptyWidget,
        );
        if (response != null) return response;

        // Lấy danh sách orders
        final orders = snapshot.data!;

        // ListView.separated cho các đơn hàng
        return ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (_, __) => Container(
            height: 8,
            color: dark ? Colors.grey[850] : Colors.grey[200],
          ),
          shrinkWrap: true,
          itemBuilder: (_, index) {
            final order = orders[index];
            // Mỗi đơn hàng, ta gói các sản phẩm trong một Container/Card
            return Container(
              // Hoặc dùng Card() tùy ý
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: dark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: dark ? Colors.black12 : Colors.grey.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "${lang.translate('order')} #${order.id?? ''}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  // Danh sách các sản phẩm trong đơn hàng
                  ListView.separated(
                    itemCount: order.items.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => Divider(
                      color: dark ? Colors.grey : Colors.grey[300],
                      thickness: 1,
                      height: 1,
                    ),
                    itemBuilder: (_, itemIndex) {
                      final CartItemModel cartItem = order.items[itemIndex];
                      return OrderItemCard(
                         item: cartItem, deliveryDate: order.deliveryDate!,
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "${lang.translate('total_order_value')}:${DFormatter.formattedAmount(order.totalAmount)}VND",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
