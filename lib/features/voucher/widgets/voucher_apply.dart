import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:my_app/utils/helper/event_logger.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/popups/loader.dart';
import '../controllers/voucher_controller.dart';
import '../models/VoucherModel.dart';

class DVoucherApply extends StatelessWidget {
  const DVoucherApply({
    super.key,
    required this.voucherFuture,
  });

  final Future<List<VoucherModel>> voucherFuture;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<VoucherModel>>(
        future: voucherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return  Center(child: Text(lang.translate('err_load_voucher')));
          }

          final vouchers = snapshot.data ?? [];
          final controller = VoucherController.instance;
          final userId = AuthenticationRepository.instance.authUser!.uid;
          return Obx((){
            // Lọc ra danh sách voucher chưa được áp dụng
            final availableVouchers = vouchers
                .where((voucher) => !controller.appliedVouchers.contains(voucher.id))
                .toList();
            // Nếu không còn voucher nào, hiển thị thông báo
            if (availableVouchers.isEmpty) {
              return  Center(child: Text(lang.translate('no_available_voucher')));
            }
            return ListView.builder(
              itemCount: availableVouchers.length,
              itemBuilder: (_, index) {
                final voucher = availableVouchers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: DColor.grey.withOpacity(0.5)),
                  ),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF0F0F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        voucher.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        voucher.description,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Obx(() {
                        final isUsed = controller.appliedVouchers.contains(voucher.id);
                        return ElevatedButton(
                          onPressed: isUsed
                              ? () {
                            TLoader.warningSnackbar(
                              title: lang.translate('voucher_has_been_used'),
                            );
                          }
                              : () async{
                            final discount = await controller.applyVoucher(voucher.id, userId);
                            await EventLogger().logEvent(eventName: 'apply_voucher',
                            additionalData: {
                              'voucher_id' :voucher.id,
                              'discount_value':discount
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUsed ? DColor.grey : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isUsed ? lang.translate('applied') : lang.translate('apply'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}
