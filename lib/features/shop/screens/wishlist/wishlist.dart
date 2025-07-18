import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:app_my_app/common/widgets/appbar/appbar.dart';
import 'package:app_my_app/common/widgets/icons/t_circular_icon.dart';
import 'package:app_my_app/common/widgets/layouts/grid_layout.dart';
import 'package:app_my_app/common/widgets/loaders/animation_loader.dart';
import 'package:app_my_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:app_my_app/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:app_my_app/features/shop/controllers/product/favourite_controller.dart';
import 'package:app_my_app/navigation_menu.dart';
import 'package:app_my_app/utils/constants/image_strings.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/helper/cloud_helper_functions.dart';

import '../../../../l10n/app_localizations.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = FavouritesController.instance;
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        title:
            Text(lang.translate('wishlist'), style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          TCircularIcon(
              icon: Iconsax.add, onPressed: () {
            final navController = Get.find<NavigationController>();
            navController.goToHome();
          },)
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          //products grid
          child: Obx(
              ()=> FutureBuilder(
                future: controller.favouriteProducts(),
                builder: (context, snapshot) {
                  //nothing found widget
                  final emptyWidget = TAnimationLoaderWidget(
                    text: lang.translate('wishlist_empty'),
                    animation: TImages.pencilAnimation,
                    showAction: true,
                    actionText: lang.translate('let_add_some'),
                    onActionPressed: () {
                      final navController = Get.find<NavigationController>();
                      navController.goToHome();
                    },
                  );
                  const loader = TVerticalProductShimmer(
                    itemCount: 6,
                  );
                  final widget = TCloudHelperFunctions.checkMultiRecordState(
                      snapshot: snapshot,
                      loader: loader,
                      nothingFound: emptyWidget);
                  if (widget != null) return widget;
                  final products = snapshot.data!;

                  return TGridLayout(
                      itemCount: products.length,
                      itemBuilder: (_, index) => TProductCardVertical(
                            product: products[index],
                          ));
                }),
          ),
        ),
      ),
    );
  }
}
