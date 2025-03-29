import 'package:flutter/material.dart';
import 'package:my_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:my_app/common/widgets/images/t_circular_image.dart';
import 'package:my_app/common/widgets/texts/product_price_text.dart';
import 'package:my_app/common/widgets/texts/product_title_text.dart';
import 'package:my_app/common/widgets/texts/t_branc_title_text_with_verified_icon.dart';
import 'package:my_app/features/shop/controllers/product_controller.dart';
import 'package:my_app/l10n/app_localizations.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/enums.dart';
import 'package:my_app/utils/constants/image_strings.dart';
import 'package:my_app/utils/constants/sizes.dart';
import 'package:my_app/utils/enum/enum.dart';
import 'package:my_app/utils/helper/helper_function.dart';

import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../models/product_model.dart';
class TProductMetaData extends StatelessWidget {
  const TProductMetaData({super.key,
    required this.product,this.salePercentage});
  final ProductModel product;
  final double? salePercentage;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final lang = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            //Sale Tag
            TProductTitleText(title: lang.translate('price')),
            if(salePercentage!=null)
            TRoundedContainer(
              radius: DSize.sm,
              backgroundColor: DColor.secondary.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(horizontal: DSize.sm,vertical: DSize.xs),
              child: Text('${controller.calculateSalePercentage(salePercentage)}%',style: Theme.of(context).textTheme.labelLarge!.apply(color: DColor.black),),
            ),
            const SizedBox(width: DSize.spaceBtwItem),

            //Price
            if(product.productType==ProductType.single.toString() && salePercentage!=null)
            Text('\$${product.price}',style: Theme.of(context).textTheme.titleSmall!.apply(decoration:TextDecoration.lineThrough)),
            if(product.productType==ProductType.single.toString() && salePercentage!=null)  const SizedBox(width: DSize.spaceBtwItem),
             TProductPriceText(price:controller.getProductPrice(product,salePercentage) ,isLarge: true),
            const SizedBox(height: DSize.spaceBtwItem/1.5),
          ],
        ),
        //Title
        TProductTitleText(title: lang.translate('product_name')),
        const SizedBox(width: DSize.spaceBtwItem),
        TProductTitleText(title: product.title),
        //Stock Status

        Row(
          children: [
            TProductTitleText(title: lang.translate('stock')),
            const SizedBox(width: DSize.spaceBtwItem),
            Text(controller.getProductStockStatus(product.stock),style: Theme.of(context).textTheme.titleMedium),
          ],
        ),

        //Branch
        Row(
          children: [
            TProductTitleText(title: lang.translate('brand')),
            const SizedBox(width: DSize.spaceBtwItem),
            TBrandTitleWithVerifiedIcon(title: product.brand!= null? product.brand!.name :" " ,
                branchTextSize: TTextSize.largre),
          ],
        ),
      ],
    );
  }
}
