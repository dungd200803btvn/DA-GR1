import 'package:app_my_app/common/widgets/products/product_cards/product_card_horizontal.dart';
import 'package:app_my_app/utils/singleton/user_singleton.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_my_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:app_my_app/features/shop/controllers/product_controller.dart';
import 'package:app_my_app/features/shop/screens/all_products/all_products.dart';
import 'package:app_my_app/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:app_my_app/features/shop/screens/home/widgets/home_categories.dart';
import 'package:app_my_app/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:app_my_app/utils/constants/colors.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../suggestion/service/RecommendationService.dart';
import '../../models/product_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    final lang = AppLocalizations.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //1. Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  //Appbar
                  const THomeAppBar(),
                  const SizedBox(
                    height: DSize.spaceBtwSection,
                  ),
                  //Search
                  TSearchContainer(
                    text: lang.translate('search_in_store'),
                  ),
                  const SizedBox(
                    height: DSize.spaceBtwSection,
                  ),
                  //Categories
                  Padding(
                    padding: EdgeInsets.only(left: DSize.defaultspace),
                    child: Column(
                      children: [
                        //Heading
                        TSectionHeading(
                            title: lang.translate('popular_category'),
                            showActionButton: false,
                            textColor: DColor.white),
                        SizedBox(height: DSize.spaceBtwItem),
                        //Categories
                        THomeCategories(),
                      ],
                    ),
                  ),
                  const SizedBox(height: DSize.spaceBtwSection)
                ],
              ),
            ),
            //2. Body
            Padding(
              padding: const EdgeInsets.all(DSize.defaultspace),
              child: Column(
                children:
                [
                  TSectionHeading(
                    title: lang.translate('personalized_recommendation'),
                    onPressed: () {
                      Get.to(
                            () => AllProducts(
                          title: lang.translate('suggest_product'),
                          futureMethod: RecommendationService.instance.getRecommendedProducts(userId: UserSession.instance.userId!),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: DSize.spaceBtwItem),

                  // Carousel Gợi ý
                  FutureBuilder<List<ProductModel>>(
                    future: RecommendationService.instance.getRecommendedProducts(userId: UserSession.instance.userId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('❌ ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('😅 Không có gợi ý cho bạn lúc này.');
                      }

                      final recommendedProducts = snapshot.data!;
                      return CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 360,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.6,
                          autoPlayInterval: const Duration(seconds: 2),
                        ),
                        itemCount: recommendedProducts.length,
                        itemBuilder: (context, index, realIdx) {
                          final product = recommendedProducts[index];
                          return Stack(
                            children: [
                              TProductCardVertical(product: product),
                              // 🔖 Tag Gợi ý
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '🔥 ${lang.translate('suggest_product')}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  //Heading
                  TSectionHeading(
                      title: lang.translate('popularProducts'),
                      onPressed: () => Get.to(
                            () => AllProducts(
                              title: lang.translate('popularProducts'),
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
