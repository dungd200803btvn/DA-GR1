import 'package:flutter/material.dart';
import 'package:app_my_app/common/widgets/appbar/appbar.dart';
import 'package:app_my_app/features/shop/screens/order/widgets/orders_list.dart';
import 'package:app_my_app/utils/constants/sizes.dart';

import '../../../../l10n/app_localizations.dart';
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(lang.translate('my_order'),style: Theme.of(context).textTheme.headlineSmall,)
        ,showBackArrow: true,),
      body: const Padding(
        padding: EdgeInsets.all(DSize.defaultspace),
        child: TOrderListItems(),
      ),
    );
  }
}
