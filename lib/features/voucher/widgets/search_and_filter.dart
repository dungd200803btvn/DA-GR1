import 'package:app_my_app/utils/formatter/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class SearchAndFilterSection extends StatelessWidget {
  final String searchQuery;
  final String selectedType;
  final Function(String) onSearchChanged;
  final Function(String) onTypeChanged;
  final List<String> voucherTypes;
  final int voucherCount;

  const SearchAndFilterSection({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedType,
    required this.onTypeChanged,
    required this.voucherTypes,
    required this.voucherCount,
  });

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Column(
        key: ValueKey('$searchQuery-$selectedType-$voucherCount'), // Trigger animation when these change
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: lang.translate('search_voucher'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) => onSearchChanged(value.toLowerCase()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${lang.translate('filter')}: ',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedType,
                      icon: const Icon(Icons.arrow_drop_down),
                      dropdownColor: Colors.white,
                      onChanged: (value) => onTypeChanged(value!),
                      items: voucherTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(DFormatter.formatVoucherType(type)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  '${lang.translate('voucher_count')}: ',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  '($voucherCount)',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
