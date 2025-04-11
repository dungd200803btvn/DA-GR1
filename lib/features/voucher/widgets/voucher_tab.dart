import 'package:app_my_app/features/voucher/widgets/search_and_filter.dart';
import 'package:app_my_app/features/voucher/widgets/voucher_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/constants/api_constants.dart';
import '../controllers/voucher_controller.dart';
import '../models/VoucherModel.dart';
import '../models/VoucherTabStatus.dart';

class DVoucherTab extends StatefulWidget {
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
  State<DVoucherTab> createState() => _DVoucherTabState();
}

class _DVoucherTabState extends State<DVoucherTab> {
  String searchQuery = '';
  String selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<VoucherModel>>(
        future: widget.voucherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(lang.translate('err_load_voucher')));
          }

          final vouchers = snapshot.data ?? [];
          final controller = VoucherController.instance;
          final userId = AuthenticationRepository.instance.authUser!.uid;

          return Obx(() {
            final _ = controller.claimedVouchers.length;
            List<VoucherModel> filteredVouchers;
            switch (widget.voucherTabStatus) {
              case VoucherTabStatus.available:
                filteredVouchers = vouchers.where((v) => !controller.allClaimedVouchers.contains(v.id)).toList();
                break;
              case VoucherTabStatus.claimed:
                filteredVouchers = vouchers.where((v) => controller.claimedVouchers.contains(v.id)).toList();
                break;
              case VoucherTabStatus.used:
              case VoucherTabStatus.expired:
                filteredVouchers = vouchers;
                break;
            }

            // Apply filters
            if (selectedType != 'All') {
              filteredVouchers = filteredVouchers.where((v) => v.type.toLowerCase() == selectedType.toLowerCase()).toList();
            }

            if (searchQuery.isNotEmpty) {
              filteredVouchers = filteredVouchers.where((v) {
                return v.title.toLowerCase().contains(searchQuery) ||
                    v.description.toLowerCase().contains(searchQuery);
              }).toList();
            }

            final displayedVouchers = widget.showAllVouchers
                ? filteredVouchers
                : filteredVouchers.take(page_voucher).toList();

            return Column(
              children: [
                SearchAndFilterSection(
                  searchQuery: searchQuery,
                  onSearchChanged: (value) => setState(() => searchQuery = value),
                  selectedType: selectedType,
                  onTypeChanged: (value) => setState(() => selectedType = value),
                  voucherTypes: voucherTypes,
                  voucherCount: filteredVouchers.length,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: displayedVouchers.isEmpty
                      ? Center(
                    child: Text(
                      lang.translate('no_available_voucher'),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                      :  ListView.builder(
                    itemCount: displayedVouchers.length,
                    itemBuilder: (_, index) {
                      final voucher = displayedVouchers[index];
                      return VoucherCard(
                        voucher: voucher,
                        buttonText: _getButtonText(lang),
                        buttonColor: _getButtonColor(),
                        warningMessage: _getWarningMessage(lang),
                        tabStatus: widget.voucherTabStatus,
                        userId: userId,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                ...filteredVouchers.length > page_voucher
                    ? [
                  ElevatedButton(
                    onPressed: widget.onToggleShowAll,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      !widget.showAllVouchers
                          ? lang.translate('show_more')
                          : lang.translate('less'),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                ]
                    : [],
              ],
            );
          });
        },
      ),
    );
  }

  String _getButtonText(AppLocalizations lang) {
    switch (widget.voucherTabStatus) {
      case VoucherTabStatus.available:
        return lang.translate('claim');
      case VoucherTabStatus.claimed:
        return lang.translate('claimed');
      case VoucherTabStatus.used:
        return lang.translate('used');
      case VoucherTabStatus.expired:
        return lang.translate('expired');
    }
  }

  Color _getButtonColor() {
    return widget.voucherTabStatus == VoucherTabStatus.available
        ? Colors.blue
        : Colors.grey;
  }

  String _getWarningMessage(AppLocalizations lang) {
    switch (widget.voucherTabStatus) {
      case VoucherTabStatus.available:
        return lang.translate('claim_voucher_msg');
      case VoucherTabStatus.claimed:
        return lang.translate('claimed_voucher_msg');
      case VoucherTabStatus.used:
        return lang.translate('used_voucher_msg');
      case VoucherTabStatus.expired:
        return lang.translate('expired_voucher_msg');
    }
  }
}
