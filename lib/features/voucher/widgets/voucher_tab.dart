import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:t_store/l10n/app_localizations.dart';
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
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: DColor.grey.withOpacity(0.5)),
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
                                  style: const TextStyle(
                                      color: Colors.black54),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    if (voucherTabStatus ==
                                        VoucherTabStatus.available) {
                                      controller.claimVoucher(voucher.id, userId);
                                    } else {
                                      TLoader.warningSnackbar(
                                          title: warningMessage);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    buttonText,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onToggleShowAll,
                      child: Text(
                          !showAllVouchers && filteredVouchers.length > 5
                              ? lang.translate('show_more')
                              : lang.translate('less')),
                    ),
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

