import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:app_my_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:app_my_app/common/widgets/layouts/grid_layout.dart';
import 'package:app_my_app/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:app_my_app/common/widgets/texts/section_heading.dart';
import 'package:app_my_app/features/shop/controllers/brand_controller.dart';
import 'package:app_my_app/features/shop/controllers/product/category_controller.dart';
import 'package:app_my_app/features/shop/screens/brand/all_brands.dart';
import 'package:app_my_app/features/shop/screens/store/widgets/shop_card.dart';
import 'package:app_my_app/navigation_menu.dart';
import 'package:app_my_app/utils/constants/colors.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/helper/event_logger.dart';
import 'package:app_my_app/utils/helper/helper_function.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/brands/t_brand_cart.dart';
import '../../../../common/widgets/shimmer/brands_shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/enum/enum.dart';
import '../../../bonus_point/handlers/mission_tracker.dart';
import '../../controllers/product/shop_controller.dart';
import '../../models/category_model.dart';
import '../../models/shop_model.dart';
import '../all_products/all_product_screen.dart';
import '../brand/brand_products.dart';
import 'all_shop.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brandController = BrandController.instance;
    final shopController = ShopController.instance;
    final lang = AppLocalizations.of(context);
    // Đảm bảo load dữ liệu shop (nên gọi ở initState nếu dùng StatefulWidget)
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('store'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: const [TCartCounterIcon()],
        showBackArrow: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Feature Brands Section ---
              TSectionHeading(
                title: lang.translate('feature_brands'),
                showActionButton: true,
                onPressed: () => Get.to(() => const AllBrandsScreen()),
              ),
              const SizedBox(height: DSize.spaceBtwItem / 1.5),
              Obx(() {
                if (brandController.isLoading.value) {
                  return const TBrandsShimmer();
                }
                if (brandController.featuredBrands.isEmpty) {
                  return Center(child: Text(lang.translate('no_brands')));
                }
                return TGridLayout(
                  itemCount: brandController.featuredBrands.length,
                  mainAxisExtent: 80,
                  itemBuilder: (_, index) {
                    final brand = brandController.featuredBrands[index];
                    return TBrandCard(
                      showBorder: true,
                      brand: brand,
                      onTap: () async {
                        await EventLogger().logEvent(
                          eventName: 'view_brand',
                          additionalData: {'brand_name': brand.name},
                        );
                        await MissionTracker.instance.track(MissionType.viewBrand, context);
                        Get.to(() => AllProductScreen(
                          title: brand.name,
                          filterId: brand.id,
                          filterType: 'brand',
                        ));
                      },
                    );
                  },
                );
              }),
              const SizedBox(height: DSize.defaultspace),

              // --- Feature Shops Section ---
              TSectionHeading(
                title: lang.translate('feature_shops'),
                showActionButton: true,
                onPressed: () => Get.to(() => const AllShopsScreen()),
              ),
              const SizedBox(height: DSize.spaceBtwItem / 1.5),
              Obx(() {
                if (shopController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (shopController.featureShops.isEmpty) {
                  return Center(child: Text(lang.translate('no_shops')));
                }
                return TGridLayout(
                  itemCount: shopController.featureShops.length,
                  mainAxisExtent: 80,
                  itemBuilder: (_, index) {
                    final shop = shopController.featureShops[index];
                    return ShopCard(
                      shop: shop,
                      onTap: () async {
                        await EventLogger().logEvent(
                          eventName: 'view_shop',
                          additionalData: {'shop_name': shop.name},
                        );
                        await MissionTracker.instance.track(MissionType.viewShop, context);
                        Get.to(() => AllProductScreen(
                          title: shop.name,
                          filterId: shop.id,
                          filterType: 'shop',
                        ));
                      }, showBorder:true,
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
