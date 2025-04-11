import 'package:app_my_app/features/shop/screens/checkout/widgets/voucher_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:app_my_app/features/shop/controllers/product/cart_controller.dart';

import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/formatter/formatter.dart';
import 'package:app_my_app/utils/helper/pricing_calculator.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../voucher/controllers/voucher_controller.dart';
import '../../../controllers/product/order_controller.dart';

class TBillingAmountSection extends StatelessWidget {
  const TBillingAmountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final orderController = OrderController.instance;
    final subTotal = cartController.totalCartPrice.value;
    final controller = VoucherController.instance;
    final lang = AppLocalizations.of(context);
    return Column(
      children: [
        //SubTotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.translate('subtotal'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${DFormatter.formattedAmount(subTotal)} VND',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(
          height: DSize.spaceBtwItem / 2,
        ),
        //Shipping Fee
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.translate('shipping_fee'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Obx(() => Text(
                  '${DFormatter.formattedAmount(orderController.fee.value)} VND',
                  style: Theme.of(context).textTheme.labelLarge,
                )),
          ],
        ),
        const SizedBox(
          height: DSize.spaceBtwItem / 2,
        ),

        ///Order total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.translate('order_total'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Obx(() => Text(
                  '${DFormatter.formattedAmount(orderController.totalAmount.value)} VND',
                  style: Theme.of(context).textTheme.labelLarge,
                )),
          ],
        ),
        const SizedBox(
          height: DSize.spaceBtwItem / 2,
        ),

        // Chèn các dòng voucher đã áp dụng (nếu có)
        Obx(
          () => Column(
            children: controller.appliedVouchersInfo.map((voucherInfo) {
              final showFull =
                  controller.expandedVouchers.contains(voucherInfo);
              final details = voucherInfo.appliedDetails ?? [];
              final visibleDetails =
                  showFull ? details : details.take(2).toList();
              final hasMore = details.length > 2;

              return Padding(
                padding: const EdgeInsets.only(bottom: DSize.spaceBtwItem / 2),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.deepPurple.shade50,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Tiêu đề voucher + số tiền giảm
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${lang.translate('voucher')}: ${voucherInfo.type}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '- ${DFormatter.formattedAmount(voucherInfo.discountValue)} VND',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        /// Chi tiết sản phẩm (nếu có)
                        if (details.isNotEmpty) ...[
                          const Divider(thickness: 1, color: Colors.deepPurple),
                          ...visibleDetails.map((detail) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 16, color: Colors.deepPurple),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      detail,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          /// Nếu có nhiều hơn 2 dòng → nút chi tiết
                          if (hasMore && !showFull)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  if (controller.expandedVouchers
                                      .contains(voucherInfo)) {
                                    controller.expandedVouchers
                                        .remove(voucherInfo);
                                  } else {
                                    controller.expandedVouchers
                                        .add(voucherInfo);
                                  }
                                  Get.to(() => VoucherDetailsScreen(
                                        voucherTitle:
                                            '${lang.translate('voucher')} - ${voucherInfo.type}',
                                        details: details,
                                      ));
                                },
                                icon: const Icon(Icons.expand_more),
                                label: Text(lang.translate('details')),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        //Net total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.translate('net_total'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Obx(() {
              return Text(
                '${DFormatter.formattedAmount(orderController.netAmount.value)}   VND',
                style: Theme.of(context).textTheme.labelLarge,
              );
            }),
          ],
        ),
      ],
    );
  }
}
