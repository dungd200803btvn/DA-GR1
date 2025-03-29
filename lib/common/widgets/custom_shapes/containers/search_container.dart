import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store_app/features/shop/controllers/home_controller.dart';
import 'package:t_store_app/features/shop/screens/all_products/all_product_run_local.dart';
import 'package:t_store_app/features/shop/screens/all_products/all_products.dart';
import 'package:t_store_app/utils/constants/colors.dart';
import 'package:t_store_app/utils/helper/event_logger.dart';
import 'package:t_store_app/utils/helper/helper_function.dart';
import 'package:t_store_app/utils/validators/validation.dart';

import '../../../../l10n/app_localizations.dart';

class TSearchContainer extends StatelessWidget {
  const TSearchContainer({
    super.key,
    required this.text,
    this.icon = Iconsax.search_normal,
    this.showBackground = true,
    this.showBorder = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = Get.put(HomeController());
    final lang = AppLocalizations.of(context);
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller.query,
        validator: (value) => DValidator.validateEmptyText("search", value),
        decoration: InputDecoration(
          filled: showBackground,
          fillColor: showBackground ? (dark ? DColor.dark : DColor.light) : Colors.transparent,
          border: showBorder ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: dark ? DColor.dark : DColor.grey),
          ) : InputBorder.none,
          hintText: lang.translate('search'),
          hintStyle: TextStyle(color: DColor.grey),
          suffixIcon: IconButton(
            icon: Icon(Iconsax.search_normal),
            color: DColor.grey,
            onPressed: () async {
              await EventLogger().logEvent(eventName: 'search',
              additionalData: {
                'search_product_name':controller.query.text.trim()
              });
              // Thực hiện hành động khi bấm vào icon search
              Get.to(() =>  AllProductsByLocal(
                title: lang.translate('search_result'),
              ));
            },
          ),
          contentPadding: const EdgeInsets.all(12.0),
        ),
      ),
    );
  }
}
