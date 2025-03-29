import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:my_app/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:my_app/features/shop/controllers/product_controller.dart';
import 'package:my_app/features/shop/screens/all_products/all_products.dart';
import 'package:my_app/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:my_app/features/shop/screens/home/widgets/home_categories.dart';
import 'package:my_app/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/sizes.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../l10n/app_localizations.dart';

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
                children: [
                  //Slider
                  const TPromoSlider(),
                  const SizedBox(
                    height: DSize.spaceBtwSection,
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
                    if (controller.isLoading.value) {
                      return const TVerticalProductShimmer();
                    }
                    if (controller.featuredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          lang.translate('no_data_found'),
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

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final ProductController controller = ProductController.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     // Nếu cần, gọi fetchFeaturedProducts() trong controller đã được gọi trong onInit của controller
//     controller.fetchFeaturedProductsPage();
//   }
//
//   Future<void> _onRefresh() async {
//     // Gọi lại fetchFeaturedProducts() khi pull-to-refresh
//     controller.fetchFeaturedProductsPage();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final lang = AppLocalizations.of(context);
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: _onRefresh,
//         child: CustomScrollView(
//           slivers: [
//             // Header: bao gồm AppBar, Search, Categories, ...
//             SliverToBoxAdapter(
//               child: TPrimaryHeaderContainer(
//                 child: Column(
//                   children: [
//                     const THomeAppBar(),
//                     const SizedBox(height: DSize.spaceBtwSection),
//                     TSearchContainer(
//                       text: lang.translate('search_in_store'),
//                     ),
//                     const SizedBox(height: DSize.spaceBtwSection),
//                     Padding(
//                       padding: const EdgeInsets.only(left: DSize.defaultspace),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           TSectionHeading(
//                             title: lang.translate('popular_category'),
//                             showActionButton: false,
//                             textColor: DColor.white,
//                           ),
//                           const SizedBox(height: DSize.spaceBtwItem),
//                           const THomeCategories(),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: DSize.spaceBtwSection),
//                   ],
//                 ),
//               ),
//             ),
//             // Phần body: slider, heading popular products
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(DSize.defaultspace),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const TPromoSlider(),
//                     const SizedBox(height: DSize.spaceBtwSection),
//                     TSectionHeading(
//                       title: lang.translate('popularProducts'),
//                       onPressed: () => Get.to(() => AllProducts(
//                         title: lang.translate('popularProducts'),
//                         query: FirebaseFirestore.instance
//                             .collection('Products')
//                             .where('IsFeatured', isEqualTo: true)
//                             .limit(20),
//                         futureMethod: controller.getAllFeaturedProducts(),
//                       )),
//                     ),
//                     const SizedBox(height: DSize.spaceBtwItem),
//
//
//
//                   ],
//                 ),
//
//               ),
//             ),
//             // Grid hiển thị sản phẩm (sử dụng SliverGrid)
//             Obx(() {
//               if (controller.isLoading.value && controller.featuredProducts.isEmpty) {
//                 return const SliverToBoxAdapter(
//                   child: Center(child: CircularProgressIndicator()),
//                 );
//               }
//               if (controller.featuredProducts.isEmpty) {
//                 return SliverToBoxAdapter(
//                   child: Center(
//                     child: Text(
//                       lang.translate('no_data_found'),
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ),
//                 );
//               }
//               // Xác định số lượng phần tử: nếu còn dữ liệu load thêm thì thêm 1 cho nút.
//               // Giả sử mỗi lần load có 20 sản phẩm
//               const int pageSize = 20;
//               final bool canLoadMore = controller.featuredProducts.length % pageSize == 0;
//               final itemCount = controller.featuredProducts.length + (canLoadMore ? 1 : 0);
//
//               return SliverPadding(
//                 padding: const EdgeInsets.all(DSize.defaultspace),
//                 sliver: SliverGrid(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: DSize.gridviewSpacing,
//                     crossAxisSpacing: DSize.gridviewSpacing,
//                     mainAxisExtent: 288,
//                   ),
//                   delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                       // Nếu index nhỏ hơn số sản phẩm -> hiển thị sản phẩm.
//                       if (index < controller.featuredProducts.length) {
//                         return TProductCardVertical(
//                           product: controller.featuredProducts[index],
//                         );
//                       } else {
//                         // Hiển thị nút "see more" trong cell cuối cùng.
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 16.0),
//                           child: SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                                 textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                 foregroundColor: Theme.of(context).primaryColor, // màu nền theo theme chính của app
//                                 backgroundColor: Colors.white, // màu chữ
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 elevation: 4.0,
//                               ),
//                               onPressed: () {
//                                 controller.loadMoreFeaturedProducts();
//                               },
//                               child: Text(lang.translate('see_more')),
//                             ),
//                           ),
//                         );
//
//                       }
//                     },
//                     childCount: itemCount,
//                   ),
//                 ),
//               );
//             }),
//
//             // Hiển thị indicator khi đang tải thêm dữ liệu (infinite scroll)
//
//           ],
//         ),
//       ),
//     );
//   }
//
// }
