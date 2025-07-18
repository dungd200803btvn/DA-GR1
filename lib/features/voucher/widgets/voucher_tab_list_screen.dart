import 'package:app_my_app/features/voucher/widgets/search_and_filter.dart';
import 'package:app_my_app/features/voucher/widgets/voucher_card.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/api_constants.dart';
import '../models/VoucherModel.dart';
import '../models/VoucherTabStatus.dart';

class DVoucherTab2 extends StatefulWidget {
  const DVoucherTab2({
    super.key,
    required this.vouchers,
    required this.showAllVouchers,
    required this.onToggleShowAll,
    this.voucherTabStatus = VoucherTabStatus.available,
  });

  final List<VoucherModel> vouchers;
  final bool showAllVouchers;
  final VoidCallback onToggleShowAll;
  final VoucherTabStatus voucherTabStatus;

  @override
  State<DVoucherTab2> createState() => _DVoucherTab2State();
}

class _DVoucherTab2State extends State<DVoucherTab2> {
  String searchQuery = '';
  String selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    final userId = AuthenticationRepository.instance.authUser!.uid;

    // Filter logic moved into build so it responds to setState
    List<VoucherModel> filteredVouchers = widget.vouchers;
    if (selectedType != 'All') {
      filteredVouchers = filteredVouchers
          .where((v) => v.type.toLowerCase() == selectedType.toLowerCase())
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filteredVouchers = filteredVouchers.where((v) {
        return v.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            v.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    final displayedVouchers = widget.showAllVouchers
        ? filteredVouchers
        : filteredVouchers.take(page_voucher).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SearchAndFilterSection(
            searchQuery: searchQuery,
            onSearchChanged: (value) {
              setState(() => searchQuery = value);
            },
            selectedType: selectedType,
            onTypeChanged: (value) {
              setState(() => selectedType = value);
            },
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
                : ListView.builder(
              itemCount: displayedVouchers.length,
              itemBuilder: (_, index) {
                final voucher = displayedVouchers[index];
                return VoucherCard(
                  voucher: voucher,
                  buttonText: lang.translate('claim'),
                  buttonColor: Colors.blue,
                  warningMessage: lang.translate('claim_voucher_msg'),
                  tabStatus: widget.voucherTabStatus,
                  userId: userId,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (filteredVouchers.length > page_voucher)
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
        ],
      ),
    );
  }
}
