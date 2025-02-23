import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/review/controller/review_controller.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:t_store/features/shop/screens/product_reviews/product_review.dart';
import 'package:t_store/l10n/app_localizations.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/enum/enum.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/products/cart/cart_menu_icon.dart';
import '../../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product, this.salePercentage});

  final ProductModel product;
  final double? salePercentage;

  @override
  Widget build(BuildContext context) {
    final controller = WriteReviewScreenController.instance;
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(product.title, style: Theme.of(context).textTheme.headlineMedium),
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
                  // 2.3 Thuộc tính
                  if (product.productType == ProductType.variable.toString())
                    ProductAttributes(product: product,salePercentage: salePercentage,),
                  if (product.productType == ProductType.variable.toString())
                    const SizedBox(height: DSize.spaceBtwSection),
                  // 2.4 Nút Thanh toán
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child:  Text( lang.translate('checkout')),
                    ),
                  ),
                  const SizedBox(height: DSize.spaceBtwSection),
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
                  // 2.6 Đánh giá
                  const Divider(),
                  const SizedBox(height: DSize.spaceBtwItem),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TSectionHeading(
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
                        onPressed: () {},
                        showActionButton: false,
                      ),

                      IconButton(
                        onPressed: () => Get.to(() =>  ProductReviewScreen(productId: product.id,)),
                        icon: const Icon(Iconsax.arrow_right_3),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSize.spaceBtwSection),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
