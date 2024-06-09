import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:t_store/features/shop/screens/product_reviews/product_review.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/enum/enum.dart';
import 'package:t_store/utils/helper/helper_function.dart';

import '../../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const TBottomAddToCart(),
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
                  const TRatingAndShare(),
                  // 2.2 Giá, Tiêu đề, Tồn kho, Chi nhánh
                  TProductMetaData(product: product),
                  // 2.3 Thuộc tính
                  if (product.productType == ProductType.variable.toString())
                    ProductAttributes(product: product),
                  if (product.productType == ProductType.variable.toString())
                    const SizedBox(height: DSize.spaceBtwSection),
                  // 2.4 Nút Thanh toán
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Checkout'),
                    ),
                  ),
                  const SizedBox(height: DSize.spaceBtwSection),
                  // 2.5 Mô tả
                  const TSectionHeading(
                    title: 'Description',
                    showActionButton: false,
                  ),
                  const SizedBox(height: DSize.spaceBtwItem),
                  ReadMoreText(
                    product.description ?? " ",
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Show more',
                    trimExpandedText: 'Less',
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
                        title: 'Review(199)',
                        onPressed: () {},
                        showActionButton: false,
                      ),
                      IconButton(
                        onPressed: () => Get.to(() => const ProductReviewScreen()),
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
