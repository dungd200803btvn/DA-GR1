import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/controllers/brand_controller.dart';
import 'package:t_store/features/shop/controllers/product/category_controller.dart';
import 'package:t_store/features/shop/screens/brand/all_brands.dart';
import 'package:t_store/features/shop/screens/store/widgets/category_tab.dart';
import 'package:t_store/features/shop/screens/store/widgets/shop_card.dart';
import 'package:t_store/navigation_menu.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helper/event_logger.dart';
import 'package:t_store/utils/helper/helper_function.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/brands/t_brand_cart.dart';
import '../../../../common/widgets/shimmer/brands_shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../controllers/product/shop_controller.dart';
import '../../models/category_model.dart';
import '../../models/shop_model.dart';
import '../all_products/all_product_screen.dart';
import '../brand/brand_products.dart';
import 'all_shop.dart';

// class StoreScreen extends StatelessWidget {
//   const StoreScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final dark = DHelperFunctions.isDarkMode(context);
//     final categories = CategoryController.instance.allCategories;
//     final controller = Get.put(BrandController());
//     final brandController = BrandController.instance;
//     final lang = AppLocalizations.of(context);
//     // Tạo danh sách các Future<CategoryModel?>
//     List<Future<CategoryModel?>> futures = categories.map((category) async {
//       final brands = await brandController.getBrandsForCategory(category.id);
//       if (brands.isNotEmpty) {
//         return category;
//       }
//       return null;
//     }).toList();
//
//     // Sử dụng FutureBuilder với Future.wait
//     return FutureBuilder<List<CategoryModel?>>(
//       future: Future.wait(futures),
//       builder: (BuildContext context, AsyncSnapshot<List<CategoryModel?>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           print('Error: ${snapshot.error}');
//           return Center(child: Text('${lang.translate('error')}: ${snapshot.error}'));
//         } else if (!snapshot.hasData || snapshot.data == null) {
//           return Center(child: Text(lang.translate('error')));
//         } else {
//           // Lọc bỏ các giá trị null khỏi kết quả
//           final validCategories = snapshot.data!.where((category) => category != null).toList();
//           // Chuyển đổi các giá trị CategoryModel? sang CategoryModel
//           final nonNullCategories = validCategories.map((category) => category!).toList();
//           return  DefaultTabController(
//             length: nonNullCategories.length,
//             child: Scaffold(
//               appBar: TAppBar(
//                 title: Text(lang.translate('store'), style: Theme.of(context).textTheme.headlineMedium),
//                 actions: const [
//                   TCartCounterIcon(),
//                 ],
//                 showBackArrow: false,
//               ),
//               body: NestedScrollView(
//                 headerSliverBuilder: (_, innerBoxIsScrolled) {
//                   return [
//                     SliverAppBar(
//                       automaticallyImplyLeading: false,
//                       pinned: true,
//                       floating: true,
//                       backgroundColor: dark ? DColor.black : DColor.white,
//                       expandedHeight: 540,
//                       flexibleSpace: Padding(
//                         padding: const EdgeInsets.all(DSize.defaultspace),
//                         child: ListView(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           children: [
//                             // Feature Brands
//                             TSectionHeading(
//                                 title: lang.translate('feature_brands'),
//                                 showActionButton: true,
//                                 onPressed: ()=> Get.to(()=> const AllBrandsScreen())),
//                             const SizedBox(height: DSize.spaceBtwItem / 1.5),
//                             Obx((){
//                                 if(controller.isLoading.value) return const TBrandsShimmer();
//                                 if(controller.featuredBrands.isEmpty) return Center(child: Text("",style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.white),),);
//                                 return TGridLayout(
//                                     itemCount: controller.featuredBrands.length,
//                                     mainAxisExtent: 80,
//                                     itemBuilder: (_, index) {
//                                       final brand = controller.featuredBrands[index];
//                                       return  TBrandCard(showBorder: true,
//                                         brand: brand,
//                                         onTap: () async{
//                                         await EventLogger().logEvent(eventName: 'view_brand',
//                                         additionalData: {
//                                           'brand_name':brand.name
//                                         });
//                                         Get.to(() => AllProductScreen(title: brand.name, filterId: brand.id, filterType: 'brand',));
//                                         } ,);
//                                     });
//                               } ,
//                             )
//                           ],
//                         ),
//                       ),
//                       bottom: PreferredSize(
//                         preferredSize: const Size.fromHeight(kToolbarHeight), // Adjust height as needed
//                         child: Obx(() {
//                           return FutureBuilder<List<ShopModel>>(
//                             future:  ,
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState == ConnectionState.waiting) {
//                                 return const Center(child: CircularProgressIndicator());
//                               } else if (snapshot.hasError) {
//                                 return Center(child: Text('${lang.translate('error')}: ${snapshot.error}'));
//                               } else {
//                                 final validCategories = snapshot.data?.where((category) => category != null).toList() ?? [];
//                                 return TabBar(
//                                   onTap: (index) async{
//                                     final selectedCategory =  validCategories[index];
//                                     if(selectedCategory!=null){
//                                       await EventLogger().logEvent(eventName: 'select_category_tab',
//                                       additionalData: {
//                                         'category_name': selectedCategory.name,
//                                       });
//                                     }
//                                   },
//                                   tabs: validCategories.map((category) => Tab(child: Text(category!.name))).toList(),
//                                   isScrollable: true,
//                                   indicatorColor: DColor.primary,
//                                   unselectedLabelColor: DColor.darkGrey,
//                                   labelColor: DHelperFunctions.isDarkMode(context)
//                                       ? DColor.white
//                                       : DColor.primary,
//                                 );
//                               }
//                             },
//                           );
//                         }),
//                       ),
//                     )
//                   ];
//                 },
//                 //
//                 body: Obx(() {
//                   return FutureBuilder<List<CategoryModel?>>(
//                     future: Future.wait(categories.map((category) async {
//                       final brands = await brandController.getBrandsForCategory(category.id);
//                       if (brands.isNotEmpty) {
//                         return category;
//                       }
//                       return null;
//                     }).toList()),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Center(child: Text('${lang.translate('error')}: ${snapshot.error}'));
//                       } else {
//                         final validCategories = snapshot.data?.where((category) => category != null).toList() ?? [];
//                         return TabBarView(
//                           children: validCategories.map((category) => TCategoryTab(category: category!)).toList(),
//                         );
//                       }
//                     },
//                   );
//                 }),
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }

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
