import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:t_store/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:t_store/features/shop/controllers/product_controller.dart';
import 'package:t_store/features/shop/screens/all_products/all_products.dart';
import 'package:t_store/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:t_store/features/shop/screens/home/widgets/home_categories.dart';
import 'package:t_store/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/constants/sizes.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/texts/section_heading.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //1. Header
            const TPrimaryHeaderContainer(
              child: Column(
                children: [
                  //Appbar
                  THomeAppBar(),
                  SizedBox(
                    height: DSize.spaceBtwSection,
                  ),

                  //Search
                  TSearchContainer(
                    text: "Search in store",
                  ),
                  SizedBox(
                    height: DSize.spaceBtwSection,
                  ),

                  //Categories
                  Padding(
                    padding: EdgeInsets.only(left: DSize.defaultspace),
                    child: Column(
                      children: [
                        //Heading
                        TSectionHeading(
                            title: 'Popular Category',
                            showActionButton: false,
                            textColor: DColor.white),
                        SizedBox(height: DSize.spaceBtwItem),
                        //Categories
                        THomeCategories(),
                      ],
                    ),
                  ),
                  SizedBox(height: DSize.spaceBtwSection)
                ],
              ),
            ),

            //2. Body
            Padding(
              padding: const EdgeInsets.all(DSize.defaultspace),
              child: Column(
                children: [
                  //Slider
                  const TPromoSlider(),

                  const SizedBox(
                    height: DSize.spaceBtwSection,
                  ),
                  //Heading
                  TSectionHeading(
                      title: 'Popular Product',
                      onPressed: () => Get.to(
                            () => AllProducts(
                              title: 'Popular Product',
                              query: FirebaseFirestore.instance
                                  .collection('Products')
                                  .where('IsFeatured', isEqualTo: true)
                                  .limit(20),
                              futureMethod: controller.getAllFeaturedProducts(),
                            ),
                          )),
                  const SizedBox(height: DSize.spaceBtwItem),
                  //Popular Product
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const TVerticalProductShimmer();
                    }
                    if (controller.featuredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No data found!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return TGridLayout(
                        itemCount: controller.featuredProducts.length,
                        itemBuilder: (_, index) => TProductCardVertical(
                            product: controller.featuredProducts[index]));
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
