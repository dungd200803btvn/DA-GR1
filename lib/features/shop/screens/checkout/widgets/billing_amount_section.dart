import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:t_store/features/shop/controllers/product/cart_controller.dart';

import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/formatter/formatter.dart';
import 'package:t_store/utils/helper/pricing_calculator.dart';

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
            Text(lang.translate('subtotal'),style: Theme.of(context).textTheme.bodyMedium,),
            Text('${DFormatter.formattedAmount(subTotal)} VND',style: Theme.of(context).textTheme.bodyMedium,),
          ],
        ),
        const SizedBox(height: DSize.spaceBtwItem/2,),
        //Shipping Fee
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lang.translate('shipping_fee'),style: Theme.of(context).textTheme.bodyMedium,),
            Obx(()=> Text('${DFormatter.formattedAmount(orderController.fee.value)} VND',style: Theme.of(context).textTheme.labelLarge,)) ,
          ],
        ),
        const SizedBox(height: DSize.spaceBtwItem/2,),
        ///Order total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lang.translate('order_total'),style: Theme.of(context).textTheme.bodyMedium,),
            Obx(()=> Text('${DFormatter.formattedAmount(orderController.totalAmount.value)} VND',style: Theme.of(context).textTheme.labelLarge,)) ,
          ],
        ),
        const SizedBox(height: DSize.spaceBtwItem/2,),

        // Chèn các dòng voucher đã áp dụng (nếu có)
        Obx(
              () => Column(
            children: controller.appliedVouchersInfo.map((voucherInfo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: DSize.spaceBtwItem / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${lang.translate('voucher')}: ${voucherInfo.type}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis, // Cắt bỏ phần text vượt quá
                        maxLines: 1,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '- ${DFormatter.formattedAmount(voucherInfo.discountValue)} VND',
                        style: Theme.of(context).textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis, // Cắt bỏ phần text vượt quá
                        maxLines: 1,
                        textAlign: TextAlign.end, // Căn chỉnh text về phía bên phải nếu cần
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        //Net total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lang.translate('net_total'),style: Theme.of(context).textTheme.bodyMedium,),
            Obx((){
             return Text('${DFormatter.formattedAmount(orderController.netAmount.value)}   VND',style: Theme.of(context).textTheme.labelLarge,);
    } ) ,
          ],
        ),
      ],
    );
  }
}
