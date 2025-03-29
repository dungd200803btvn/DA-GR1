import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:app_my_app/common/widgets/texts/section_heading.dart';
import 'package:app_my_app/features/review/controller/review_controller.dart';
import 'package:app_my_app/features/shop/controllers/product/cart_controller.dart';
import 'package:app_my_app/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart';
import 'package:app_my_app/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:app_my_app/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:app_my_app/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:app_my_app/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:app_my_app/features/shop/screens/product_reviews/product_review.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/enum/enum.dart';
import 'package:app_my_app/utils/helper/event_logger.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/products/cart/cart_menu_icon.dart';
import '../../../review/screen/review_screen.dart';
import '../../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product, this.salePercentage});

  final ProductModel product;

  final double? salePercentage;

  @override
  Widget build(BuildContext context) {
    final controller = WriteReviewScreenController.instance;
    final cartController = CartController.instance;
    final item = cartController.toCartModel(product, 1);
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
        actions: const [
          TCartCounterIcon(),
        ],
      ),
      bottomNavigationBar:  TBottomAddToCart(product: product,salePercentage: salePercentage,),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SLIDER ẢNH SẢN PHẨM
            TProductImageSlider(product: product),
            // 2. CHI TIẾT SẢN PHẨM
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSize.defaultspace,
                vertical: DSize.defaultspace,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2.1 Xếp hạng và chia sẻ
                  TRatingAndShare(productId: product.id,),
                  // 2.2 Giá, Tiêu đề, Tồn kho, Chi nhánh
                  TProductMetaData(product: product,salePercentage: salePercentage),
                  const Divider(),
                  // 2.5 Mô tả
                   TSectionHeading(
                    title: lang.translate('description'),
                    showActionButton: false,
                  ),
                  const SizedBox(height: DSize.spaceBtwItem),
                  ReadMoreText(
                    product.description ?? " ",
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: lang.translate('show_more'),
                    trimExpandedText: lang.translate('less'),
                    moreStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    lessStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(),
                  //2.6 Detail
                  const SizedBox(height: DSize.spaceBtwItem),
                  TSectionHeading(
                    title: lang.translate('detail'),
                    showActionButton: false,
                  ),
                  ReadMoreText(
                    product.details !=null ? product.details!.entries.map((entry)=>"${entry.key}: ${entry.value}").join('\n'):'',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: lang.translate('show_more'),
                    trimExpandedText: lang.translate('less'),
                    moreStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    lessStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // 2.6 Đánh giá
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TSectionHeading(
                          titleWidget: FutureBuilder<int>(
                            future: controller.fetchTotalReviews(product.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text('${lang.translate('review')}(...)'); // Loading
                              }
                              if (snapshot.hasError) {
                                return Text('${lang.translate('review')}(0)'); // Nếu lỗi thì hiển thị 0
                              }
                              final int totalReviews = snapshot.data ?? 0;
                              return Text('${lang.translate('review')}($totalReviews)');
                            },
                          ),
                          onPressed: () async{
                            await EventLogger().logEvent(eventName: 'navigate_to_review',
                                additionalData: {
                                  'product_id':product.id
                                });
                            Get.to(() =>  ProductReviewScreen(productId: product.id,));
                          },
                          showActionButton: false,
                        ),
                      ),

                      IconButton(
                        onPressed: () async{
                          await EventLogger().logEvent(eventName: 'navigate_to_review',
                          additionalData: {
                            'product_id':product.id
                          });
                          Get.to(() =>  ProductReviewScreen(productId: product.id,));
    },
                        icon: const Icon(Iconsax.arrow_right_3),
                      ),
                    ],
                  ),
                  // 2.4 Nút Review
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        await EventLogger().logEvent(eventName: 'write_review',
                            additionalData: {
                              'product_id':product.id
                            });
                        Get.to(()=> WriteReviewScreen(item: item,) );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        lang.translate('write_review'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
