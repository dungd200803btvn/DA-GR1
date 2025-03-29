import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:t_store_app/features/shop/controllers/product/shop_controller.dart';
import 'package:t_store_app/features/shop/screens/store/widgets/shop_card.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/shimmer/brands_shimmer.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helper/helper_function.dart';
import '../all_products/all_product_screen.dart';

class AllShopsScreen extends StatelessWidget {
  const AllShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ShopController.instance;
    final lang = AppLocalizations.of(context);
    final dark = DHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('store'),
          style: TextStyle(color: dark ? Colors.white : Colors.black),
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Column(
            children: [
              //Heading
              TSectionHeading(
                title: lang.translate('store'),
                showActionButton: false,
              ),
              const SizedBox(
                height: DSize.spaceBtwItem,
              ),
              //Brands
              Obx(
                    () {
                  if (controller.isLoading.value) return const TBrandsShimmer();
                  if (controller.allShops.isEmpty) {
                    return Center(
                      child: Text(
                        lang.translate('no_data_found'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .apply(color: Colors.white),
                      ),
                    );
                  }
                  return TGridLayout(
                      itemCount: controller.allShops.length,
                      mainAxisExtent: 80,
                      itemBuilder: (_, index) {
                        final shop = controller.allShops[index];
                        return ShopCard(
                          showBorder: true,
                          shop: shop,
                          onTap: () {
                            Get.to(() => AllProductScreen(
                              title: shop.name,
                              filterId: shop.id,
                              filterType: 'shop',
                            ));
                          },
                        );
                      });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}