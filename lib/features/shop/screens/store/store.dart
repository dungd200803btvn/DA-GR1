import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/controllers/brand_controller.dart';
import 'package:t_store/features/shop/controllers/product/category_controller.dart';
import 'package:t_store/features/shop/screens/brand/all_brands.dart';
import 'package:t_store/features/shop/screens/store/widgets/category_tab.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helper/helper_function.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/brands/t_brand_cart.dart';
import '../../../../common/widgets/shimmer/brands_shimmer.dart';
import '../brand/brand_products.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final categories = CategoryController.instance.featuredCategories;
    final controller = Get.put(BrandController());
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: TAppBar(
          title: Text('Store', style: Theme.of(context).textTheme.headlineMedium),
          actions: [
            TCartCounterIcon(onPressed: () {}),
          ],
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
                      //Search Bar
                      const SizedBox(height: DSize.spaceBtwItem),
                      const TSearchContainer(
                        text: 'Search in store',
                        showBorder: true,
                        showBackground: false,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: DSize.spaceBtwSection),
                      // Feature Brands
                      TSectionHeading(
                          title: 'Feature Brands',
                          showActionButton: true,
                          onPressed: ()=> Get.to(()=> const AllBrandsScreen())),
                      const SizedBox(height: DSize.spaceBtwItem / 1.5),
                      Obx(
                          (){
                            if(controller.isLoading.value) return const TBrandsShimmer();
                            if(controller.featuredBrands.isEmpty) return Center(child: Text("No Data Found!",style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.white),),);

                            return TGridLayout(
                                itemCount: controller.featuredBrands.length,
                                mainAxisExtent: 80,
                                itemBuilder: (_, index) {
                                  final brand = controller.featuredBrands[index];
                                  return  TBrandCard(showBorder: true, brand: brand,onTap: ()=> Get.to(()=>BrandProducts(brand:brand,)),);
                                });
                          } ,
                      )
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight), // Adjust height as needed
                  child: Obx(
                        () => TabBar(
                      tabs: categories.map((category) => Tab(child: Text(category.name))).toList(),
                      isScrollable: true,
                      indicatorColor: DColor.primary,
                      unselectedLabelColor: DColor.darkGrey,
                      labelColor: DHelperFunctions.isDarkMode(context)
                          ? DColor.white
                          : DColor.primary,
                    ),
                  ),
                ),

              )
            ];
          },
          body:  Obx(
              ()=> TabBarView(
              children: categories.map((category) =>TCategoryTab(category: category)).toList()
            ),
          ),
        ),
      ),
    );
  }
}


