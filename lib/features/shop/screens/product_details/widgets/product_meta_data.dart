import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:t_store/common/widgets/images/t_circular_image.dart';
import 'package:t_store/common/widgets/texts/product_price_text.dart';
import 'package:t_store/common/widgets/texts/product_title_text.dart';
import 'package:t_store/common/widgets/texts/t_branc_title_text_with_verified_icon.dart';
import 'package:t_store/features/shop/controllers/product_controller.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/enums.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/enum/enum.dart';
import 'package:t_store/utils/helper/helper_function.dart';

import '../../../models/product_model.dart';
class TProductMetaData extends StatelessWidget {
  const TProductMetaData({super.key,
    required this.product});
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final salePercentage =  controller.calculateSalePercentage(product.price, product.salePrice);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Price && Sale price
        Row(
          children: [
            //Sale Tag
            TRoundedContainer(
              radius: DSize.sm,
              backgroundColor: DColor.secondary.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(horizontal: DSize.sm,vertical: DSize.xs),
              child: Text('$salePercentage%',style: Theme.of(context).textTheme.labelLarge!.apply(color: DColor.black),),
            ),
            const SizedBox(width: DSize.spaceBtwItem),

            //Price
            if(product.productType==ProductType.single.toString() && product.salePrice>0)
            Text('\$${product.price}',style: Theme.of(context).textTheme.titleSmall!.apply(decoration:TextDecoration.lineThrough)),
            if(product.productType==ProductType.single.toString() && product.salePrice>0)  const SizedBox(width: DSize.spaceBtwItem),
             TProductPriceText(price:controller.getProductPrice(product) ,isLarge: true),
            const SizedBox(height: DSize.spaceBtwItem/1.5),
          ],
        ),
        //Title
         TProductTitleText(title: product.title),
        const SizedBox(height: DSize.spaceBtwItem/1.5),
        //Stock Status
        Row(
          children: [
             TProductTitleText(title: 'Status'),
            const SizedBox(width: DSize.spaceBtwItem),
            Text(controller.getProductStockStatus(product.stock),style: Theme.of(context).textTheme.titleMedium),
          ],
        ),

        const SizedBox(height: DSize.spaceBtwItem/1.5),
        //Branch
        Row(
          children: [
            TCircularImage(image: product.brand!= null? product.brand!.image :" ",
                width: 32,height: 32,overlayColor: dark? DColor.white:DColor.black),
            TBrandTitleWithVerifiedIcon(title: product.brand!= null? product.brand!.name :" " ,
                branchTextSize: TTextSize.medium),
          ],
        ),
      ],
    );
  }
}
