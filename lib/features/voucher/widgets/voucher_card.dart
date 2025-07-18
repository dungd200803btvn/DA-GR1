import 'package:app_my_app/features/shop/screens/cart/cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../utils/helper/event_logger.dart';
import '../../../utils/popups/loader.dart';
import '../controllers/voucher_controller.dart';
import '../models/VoucherModel.dart';
import '../models/VoucherTabStatus.dart';

class VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final String buttonText;
  final String warningMessage;
  final Color buttonColor;
  final VoucherTabStatus tabStatus;
  final String userId;

  const VoucherCard({super.key,
    required this.voucher,
    required this.buttonText,
    required this.warningMessage,
    required this.buttonColor,
    required this.tabStatus,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = VoucherController.instance;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(
              voucher.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                voucher.description,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            trailing: InkWell(
              onTap: () async {
                await EventLogger().logEvent(
                  eventName: 'claim_voucher',
                  additionalData: {'voucher_id': voucher.id},
                );
                if (tabStatus == VoucherTabStatus.available) {
                  controller.claimVoucher(voucher.id, userId);
                  TLoader.successSnackbar(title: warningMessage);
                } else if(tabStatus == VoucherTabStatus.claimed) {
                  TLoader.successSnackbar(title: warningMessage);
                  Get.to(()=> const CartScreen());
                }else{
                  TLoader.warningSnackbar(title: warningMessage);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purpleAccent, Colors.deepPurple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      buttonText,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
