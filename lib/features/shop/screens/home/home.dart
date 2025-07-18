import 'package:app_my_app/features/shop/controllers/home_service.dart';
import 'package:app_my_app/features/shop/controllers/recommendation_controller.dart';
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
import 'package:app_my_app/utils/constants/colors.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../suggestion/service/RecommendationService.dart';
import '../../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = Get.put(ProductController());
  final recommendationController = RecommendationController.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeService.instance.handleDynamicLinks(context);
      // ✅ Chỉ gọi API nếu chưa có data
      if (!recommendationController.isLoaded.value) {
        recommendationController
            .fetchRecommendations(UserSession.instance.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //1. Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  const THomeAppBar(),
                  const SizedBox(height: DSize.spaceBtwSection),
                  TSearchContainer(text: lang.translate('search_in_store')),
                  const SizedBox(height: DSize.spaceBtwSection),
                  Padding(
                    padding: EdgeInsets.only(left: DSize.defaultspace),
                    child: Column(
                      children: [
                        TSectionHeading(
                          title: lang.translate('popular_category'),
                          showActionButton: false,
                          textColor: DColor.white,
                        ),
                        SizedBox(height: DSize.spaceBtwItem),
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
                children: [
                  TSectionHeading(
                    title: lang.translate('personalized_recommendation'),
                    onPressed: () {
                      Get.to(() => AllProducts(
                            title: lang.translate('suggest_product'),
                            products:
                                recommendationController.recommendedProducts,
                          ));
                    },
                  ),
                  const SizedBox(height: DSize.spaceBtwItem),

                  /// Carousel gợi ý
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 360,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.6,
                      autoPlayInterval: const Duration(seconds: 2),
                    ),
                    itemCount: recommendationController.recommendedProducts.length,
                    itemBuilder: (context, index, realIdx) {
                      final product = recommendationController.recommendedProducts[index];
                      return Stack(
                        children: [
                          TProductCardVertical(product: product),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '🔥 ${lang.translate('suggest_product')}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  /// Popular
                  TSectionHeading(
                    title: lang.translate('popularProducts'),
                    showActionButton: false,
                    onPressed: () => Get.to(() => AllProducts(
                          title: lang.translate('popularProducts'),
                          query: FirebaseFirestore.instance
                              .collection('Products')
                              .where('IsFeatured', isEqualTo: true)
                              .limit(20),
                          futureMethod: controller.getAllFeaturedProducts(),
                        )),
                  ),
                  const SizedBox(height: DSize.spaceBtwItem),
                  Obx(() {
                    return TGridLayout(
                      itemCount: controller.featuredProducts.length,
                      itemBuilder: (_, index) => TProductCardVertical(
                        product: controller.featuredProducts[index],
                      ),
                    );
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
