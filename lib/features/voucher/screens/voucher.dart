import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:app_my_app/features/voucher/controllers/voucher_controller.dart';
import 'package:app_my_app/features/voucher/screens/voucher_history.dart';
import 'package:app_my_app/features/voucher/widgets/voucher_tab.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import 'package:app_my_app/utils/constants/colors.dart';
import 'package:app_my_app/utils/helper/event_logger.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helper/cloud_helper_functions.dart';
import '../../../utils/popups/loader.dart';
import '../models/VoucherModel.dart';
import '../widgets/voucher_tab_list_screen.dart';

class VoucherScreen extends StatefulWidget {
  final String userId;
  const VoucherScreen({super.key, required this.userId});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final controller = VoucherController.instance;

  bool showAllVouchers = false;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DColor.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          lang.translate('vouchers_list'),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'history') {
                EventLogger().logEvent(eventName: 'navigate_to_voucher_history');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(userId: widget.userId),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'history',
                  child: Text(lang.translate('vouchers_history')),
                ),
              ];
            },
          ),
        ],
      ),
      body: Obx(() {
        final vouchers = controller.allVouchers
            .where((voucher) => !controller.allClaimedVoucherModel.any((claimed) => claimed.id == voucher.id))
            .toList();
        return DVoucherTab2(
          vouchers: vouchers,
          showAllVouchers: showAllVouchers,
          onToggleShowAll: () {
            setState(() {
              showAllVouchers = !showAllVouchers;
            });
          },
        );
      })

    );
  }
}
