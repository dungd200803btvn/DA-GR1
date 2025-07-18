import 'package:flutter/material.dart';

class VoucherDetailsScreen extends StatelessWidget {
  final String voucherTitle;
  final List<String> details;

  const VoucherDetailsScreen({
    Key? key,
    required this.voucherTitle,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(voucherTitle),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: details.length,
        itemBuilder: (context, index) {
          final detail = details[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.label_outline, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    detail,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
