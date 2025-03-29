import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:lcd_ecommerce_app/common/widgets/texts/product_price_text.dart';
import 'package:lcd_ecommerce_app/common/widgets/texts/product_title_text.dart';
import 'package:lcd_ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:lcd_ecommerce_app/features/shop/controllers/product/variation_controller.dart';
import 'package:lcd_ecommerce_app/l10n/app_localizations.dart';
import 'package:lcd_ecommerce_app/utils/constants/colors.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';
import 'package:lcd_ecommerce_app/utils/formatter/formatter.dart';
import 'package:lcd_ecommerce_app/utils/helper/helper_function.dart';
import 'package:lcd_ecommerce_app/utils/popups/loader.dart';

import '../../../../../common/widgets/chips/choice_chip.dart';
import '../../../models/product_model.dart';

class ProductAttributes extends StatelessWidget {
  const ProductAttributes({super.key, required this.product,this.salePercentage});

  final ProductModel product;
  final double? salePercentage;
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VariationController());
    final dark = DHelperFunctions.isDarkMode(context);
    final lang = AppLocalizations.of(context);
    return Obx(
        ()=> Column(
        children: [
          //Selected attributes pricing and description
          //display variation price and stock when some attributes selected
          if (controller.selectedVariation.value.id.isNotEmpty)
            TRoundedContainer(
              padding: const EdgeInsets.all(DSize.md),
              backgroundColor: dark ? DColor.darkerGrey : DColor.grey,
              child: Column(
                children: [
                  //Title,price,stock
                  Row(
                    children: [
                      //Title
                      Expanded(
                        child: TSectionHeading(
                            title: lang.translate('variation'), showActionButton: false),
                      ),
                      const SizedBox(width: DSize.spaceBtwItem),
                      //Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Price
                          Row(
                            children: [
                               TProductTitleText(
                                  title: lang.translate('price'), smallSize: true),
                              //Actual price
                              if(salePercentage!=null)
                              Text(DFormatter.formattedAmount(controller.selectedVariation.value.price),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .apply(
                                          decoration:
                                              TextDecoration.lineThrough)),
                              //Sale price
                              const SizedBox(width: DSize.spaceBtwItem / 2),
                               TProductPriceText(price: controller.getVariationPrice(salePercentage))
                            ],
                          ),
                          //Stock
                          Row(
                            children: [
                               TProductTitleText(
                                  title: lang.translate('stock'), smallSize: true),
                              const SizedBox(width: DSize.spaceBtwItem / 2),
                              Text(controller.selectedVariation.value.stock.toString(),
                                  style: Theme.of(context).textTheme.titleMedium),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
      
                  //Variation Description
                   TProductTitleText(
                      title:
                        controller.selectedVariation.value.description ?? lang.translate('variation_mes') ,
                      smallSize: true,
                      maxLines: 4),
                ],
              ),
            ),
          const SizedBox(height: DSize.spaceBtwItem),
          //Attributes
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: product.productAttributes!
                  .map(
                    (e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TSectionHeading(
                            title: e.name ?? " ", showActionButton: false),
                        const SizedBox(height: DSize.spaceBtwItem / 2),
                        Obx(
                          () => Wrap(
                              spacing: 8,
                              children: e.values!.map((val) {
                                final isSelected =
                                    controller.selectedAttributes[e.name] == val;
                                final available = controller
                                    .getAttributesAvailabilityVariation(
                                        product.productVariations!, e.name!)
                                    .contains(val);
      
                                return TChoiceChip(
                                  text: val,
                                  selected: isSelected,
                                  onSelected: available? (selected) async{
                                    if( available && selected){
                                   await   controller.onAttributeSelected(
                                          product, e.name ?? " ", val);
                                    }
                                  }:null,

                                );
                              }).toList()),
                        )
                      ],
                    ),
                  )
                  .toList()),
        ],
      ),
    );
  }
}
