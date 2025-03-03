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
import 'package:t_store/navigation_menu.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helper/helper_function.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/brands/t_brand_cart.dart';
import '../../../../common/widgets/shimmer/brands_shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../brand/brand_products.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final categories = CategoryController.instance.allCategories;
    final controller = Get.put(BrandController());
    final brandController = BrandController.instance;
    final lang = AppLocalizations.of(context);
    // Tạo danh sách các Future<CategoryModel?>
    List<Future<CategoryModel?>> futures = categories.map((category) async {
      final brands = await brandController.getBrandsForCategory(category.id);
      if (brands.isNotEmpty) {
        return category;
      }
      return null;
    }).toList();

    // Sử dụng FutureBuilder với Future.wait
    return FutureBuilder<List<CategoryModel?>>(
      future: Future.wait(futures),
      builder: (BuildContext context, AsyncSnapshot<List<CategoryModel?>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('${lang.translate('error')}: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text(lang.translate('error')));
        } else {
          // Lọc bỏ các giá trị null khỏi kết quả
          final validCategories = snapshot.data!.where((category) => category != null).toList();
          // Chuyển đổi các giá trị CategoryModel? sang CategoryModel
          final nonNullCategories = validCategories.map((category) => category!).toList();
          return  DefaultTabController(
            length: nonNullCategories.length,
            child: Scaffold(
              appBar: TAppBar(
                title: Text(lang.translate('store'), style: Theme.of(context).textTheme.headlineMedium),
                actions: const [
                  TCartCounterIcon(),
                ],
                showBackArrow: true,
                leadingOnPressed: () async {
                  await Get.to(() => const NavigationMenu());
                },
              ),
              body: NestedScrollView(
                headerSliverBuilder: (_, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      pinned: true,
                      floating: true,
                      backgroundColor: dark ? DColor.black : DColor.white,
                      expandedHeight: 540,
                      flexibleSpace: Padding(
                        padding: const EdgeInsets.all(DSize.defaultspace),
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Feature Brands
                            TSectionHeading(
                                title: lang.translate('feature_brands'),
                                showActionButton: true,
                                onPressed: ()=> Get.to(()=> const AllBrandsScreen())),
                            const SizedBox(height: DSize.spaceBtwItem / 1.5),
                            Obx(
                                  (){
                                if(controller.isLoading.value) return const TBrandsShimmer();
                                if(controller.featuredBrands.isEmpty) return Center(child: Text("",style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.white),),);
                                return TGridLayout(
                                    itemCount: controller.allBrands.length,
                                    mainAxisExtent: 80,
                                    itemBuilder: (_, index) {
                                      final brand = controller.allBrands[index];
                                      return  TBrandCard(showBorder: true, brand: brand,onTap: ()=> Get.to(()=>BrandProducts(brand:brand,)),);
                                    });
                              } ,
                            )
                          ],
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight), // Adjust height as needed
                        child: Obx(() {
                          return FutureBuilder<List<CategoryModel?>>(
                            future: Future.wait(categories.map((category) async {
                              final brands = await brandController.getBrandsForCategory(category.id);
                              if (brands.isNotEmpty) {
                                return category;
                              }
                              return null;
                            }).toList()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('${lang.translate('error')}: ${snapshot.error}'));
                              } else {
                                final validCategories = snapshot.data?.where((category) => category != null).toList() ?? [];
                                return TabBar(
                                  tabs: validCategories.map((category) => Tab(child: Text(category!.name))).toList(),
                                  isScrollable: true,
                                  indicatorColor: DColor.primary,
                                  unselectedLabelColor: DColor.darkGrey,
                                  labelColor: DHelperFunctions.isDarkMode(context)
                                      ? DColor.white
                                      : DColor.primary,
                                );
                              }
                            },
                          );
                        }),
                      ),
                    )
                  ];
                },
                //
                body: Obx(() {
                  return FutureBuilder<List<CategoryModel?>>(
                    future: Future.wait(categories.map((category) async {
                      final brands = await brandController.getBrandsForCategory(category.id);
                      if (brands.isNotEmpty) {
                        return category;
                      }
                      return null;
                    }).toList()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('${lang.translate('error')}: ${snapshot.error}'));
                      } else {
                        final validCategories = snapshot.data?.where((category) => category != null).toList() ?? [];
                        return TabBarView(
                          children: validCategories.map((category) => TCategoryTab(category: category!)).toList(),
                        );
                      }
                    },
                  );
                }),
              ),
            ),
          );
        }
      },
    );
  }
}
