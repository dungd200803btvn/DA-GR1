import 'package:flutter/material.dart';
import 'package:lcd_ecommerce_app/features/voucher/widgets/voucher_apply.dart';
import 'package:lcd_ecommerce_app/utils/helper/event_logger.dart';
import '../../../../features/voucher/controllers/voucher_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helper/helper_function.dart';
import '../../custom_shapes/containers/rounded_container.dart';

class TCouponCode extends StatefulWidget {
  const TCouponCode({
    super.key,
    required this.totalValue,
    required this.userId,
  });
  final double totalValue;
  final String userId;

  @override
  State<TCouponCode> createState() => _TCouponCodeState();
}

class _TCouponCodeState extends State<TCouponCode> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = VoucherController.instance;
    final lang = AppLocalizations.of(context);
    return TRoundedContainer(
      showBorder: true,
      backgroundColor: dark ? DColor.dark : DColor.white,
      padding: const EdgeInsets.only(
        top: DSize.sm,
        bottom: DSize.sm,
        right: DSize.md,
        left: DSize.md,
      ),
      child: Row(
        children: [
          // Input text cho mã khuyến mại
          Expanded(
            child: TextFormField(
              controller: _promoController,
              decoration:  InputDecoration(
                hintText: lang.translate('have_promo_code'),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          // Nút Apply
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: () async {
                await EventLogger().logEvent(eventName: 'view_voucher');
                // Nếu không có mã khuyến mại nào được nhập
                if (_promoController.text.trim().isEmpty) {
                  // Hiển thị popup toàn bộ các voucher người dùng đã thu thập
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return DVoucherApply(
                        voucherFuture: controller.getApplicableVouchers(),
                      );
                    },
                  );
                } else {
                  // Nếu có nhập mã khuyến mại, gọi hàm kiểm tra voucher áp dụng theo tổng đơn hàng và userId
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return DVoucherApply(
                        voucherFuture: controller.getApplicableVouchers(),
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: dark
                    ? DColor.white.withOpacity(0.5)
                    : DColor.dark.withOpacity(0.5),
                backgroundColor: DColor.grey.withOpacity(0.2),
                side: BorderSide(color: DColor.grey.withOpacity(0.1)),
              ),
              child:  Text(lang.translate('apply')),
            ),
          ),
        ],
      ),
    );
  }
}
