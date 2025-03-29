import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import 'package:app_my_app/utils/helper/event_logger.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/popups/loader.dart';
import '../controllers/voucher_controller.dart';
import '../models/VoucherModel.dart';
import '../models/VoucherTabStatus.dart';

class DVoucherTab extends StatelessWidget {
  const DVoucherTab({
    super.key,
    required this.voucherFuture,
    required this.showAllVouchers,
    required this.onToggleShowAll,
    this.voucherTabStatus = VoucherTabStatus.available,
  });

  final Future<List<VoucherModel>> voucherFuture;
  final bool showAllVouchers;
  final VoidCallback onToggleShowAll;
  final VoucherTabStatus voucherTabStatus;

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

          // Di chuyển phần lọc dựa vào biến Rx vào bên trong Obx
          return Obx(() {
            // Ép GetX theo dõi biến Rx (dummy read)
            final _ = controller.claimedVouchers.length;
            // Lọc danh sách voucher dựa trên trạng thái của tab
            List<VoucherModel> filteredVouchers;
            switch (voucherTabStatus) {
              case VoucherTabStatus.available:
                filteredVouchers = vouchers
                    .where((voucher) =>
                !controller.claimedVouchers.contains(voucher.id))
                    .toList();
                break;
              case VoucherTabStatus.claimed:
                filteredVouchers = vouchers
                    .where((voucher) =>
                    controller.claimedVouchers.contains(voucher.id))
                    .toList();
                break;
              case VoucherTabStatus.used:
              // Giả sử bạn có danh sách used vouchers trong controller (ví dụ: controller.usedVouchers)
                filteredVouchers = vouchers;
                break;
              case VoucherTabStatus.expired:
                filteredVouchers = vouchers;
                break;
            }
            // Lấy ra danh sách cần hiển thị dựa vào showAllVouchers
            final displayedVouchers = showAllVouchers
                ? filteredVouchers
                : filteredVouchers.take(5).toList();

            // Nếu không còn voucher nào, hiển thị thông báo
            if (displayedVouchers.isEmpty) {
              return  Center(child: Text(lang.translate('no_available_voucher')));
            }

            // Xác định nội dung nút dựa trên trạng thái của tab
            String buttonText;
            String warningMessage;
            Color buttonColor;
            switch (voucherTabStatus) {
              case VoucherTabStatus.available:
                buttonText = lang.translate('claim');
                warningMessage =  lang.translate('claim_voucher_msg');
                buttonColor = Colors.blue;
                break;
              case VoucherTabStatus.claimed:
                buttonText = lang.translate('claimed');
                warningMessage =  lang.translate('claimed_voucher_msg');
                buttonColor = DColor.grey;
                break;
              case VoucherTabStatus.used:
                buttonText = lang.translate('used');
                warningMessage =  lang.translate('used_voucher_msg');
                buttonColor = DColor.grey;
                break;
              case VoucherTabStatus.expired:
                buttonText = lang.translate('expired');
                warningMessage =  lang.translate('expired_voucher_msg');
                buttonColor = DColor.grey;
                break;
            }

            // Sử dụng LayoutBuilder để đảm bảo Column có ràng buộc chiều cao
            return LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayedVouchers.length,
                        itemBuilder: (_, index) {
                          final voucher = displayedVouchers[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              shadowColor: Colors.black26,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.blue.shade50, // Màu gradient nhẹ nhàng
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  title: Text(
                                    voucher.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      voucher.description,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () async {
                                      await EventLogger().logEvent(
                                        eventName: 'claim_voucher',
                                        additionalData: {'voucher_id': voucher.id},
                                      );
                                      if (voucherTabStatus == VoucherTabStatus.available) {
                                        controller.claimVoucher(voucher.id, userId);
                                      } else {
                                        TLoader.warningSnackbar(title: warningMessage);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor, // Màu sắc đã định nghĩa của bạn
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: Text(
                                      buttonText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onToggleShowAll,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        !showAllVouchers && filteredVouchers.length > 5
                            ? lang.translate('show_more')
                            : lang.translate('less'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          });
        },
      ),
    );
  }
}

