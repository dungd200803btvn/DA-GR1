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


import '../../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final ProductModel product;
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      bottomNavigationBar: const TBottomAddToCart(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //1. PRODUCT IMAGE SLIDER
            TProductImageSlider(product: product,),
            //2. PRODUCT DETAIL
            Padding(padding: const EdgeInsets.only(right: DSize.defaultspace,left: DSize.defaultspace,bottom: DSize.defaultspace),
              child: Column(
                children: [
                  //2.1 Rating && Share
                  const TRatingAndShare(),
                  //2.2 Price,Title,Stock,Branch
                  TProductMetaData(product: product,),
                  //2.3 Attributes
                  if(product.productType== ProductType.variable.toString())   ProductAttributes(product: product,),
                  if(product.productType== ProductType.variable.toString())  const SizedBox(height: DSize.spaceBtwSection),
                  //2.4 Checkout Button

                  SizedBox(width: double.infinity,child: ElevatedButton(onPressed: (){},child: const Text('Checkout'),),),
                  const SizedBox(height: DSize.spaceBtwSection),
                  //2.5 Description
                  const TSectionHeading(title: 'Description',showActionButton: false),
                  const SizedBox(height: DSize.spaceBtwItem),
                  ReadMoreText(
                    product.description ?? " ",
                    trimLines: 2,//so dong toi da
                    trimMode: TrimMode.Line,//giu nguyen cac tu va tu ngat neu vuot qua 2 dong
                    trimCollapsedText: 'Show more',
                    trimExpandedText: 'Less',
                    moreStyle: TextStyle(fontSize: 14,fontWeight: FontWeight.w800),
                    lessStyle: TextStyle(fontSize: 14,fontWeight: FontWeight.w800),

                  ),
                  //2.6 Review
                  const Divider(),
                  const SizedBox(height: DSize.spaceBtwItem),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TSectionHeading(title: 'Review(199)',onPressed: (){},showActionButton: false,),
                      IconButton(onPressed: ()=> Get.to(()=> const ProductReviewScreen()), icon: const Icon(Iconsax.arrow_right_3))
                    ],
                  ),
                  const SizedBox(height: DSize.spaceBtwSection)
                ],
              ),)
          ],
        ),
      ),
    );
  }
}