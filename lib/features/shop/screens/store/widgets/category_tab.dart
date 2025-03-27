import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:t_store/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/controllers/product/category_controller.dart';
import 'package:t_store/features/shop/models/category_model.dart';
import 'package:t_store/features/shop/screens/all_products/all_products.dart';
import 'package:t_store/features/shop/screens/store/widgets/category_brands.dart';
import 'package:t_store/l10n/app_localizations.dart';
import 'package:t_store/utils/helper/cloud_helper_functions.dart';
import 'package:t_store/utils/helper/event_logger.dart';
import '../../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../../common/widgets/products/product_cards/product_card_vertical.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/brand_controller.dart';

class TCategoryTab extends StatelessWidget {
  const TCategoryTab({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    final lang = AppLocalizations.of(context);
    return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(DSize.defaultspace),
            child: Column(
              children: [
                // Brands

                CategoryBrands(category: category),
                const SizedBox(height: DSize.spaceBtwItem),

                ///Products
                FutureBuilder(
                  future: controller.getCategoryProducts(categoryId: category.id),
                  builder: ( context,  snapshot) {
                    final response = TCloudHelperFunctions.checkMultiRecordState(
                        snapshot: snapshot,loader: const TVerticalProductShimmer());
                    if(response!=null) return response;
                    //record found!
                    final products = snapshot.data!;

                    return Column(
                      children: [
                        TSectionHeading(title: lang.translate('you_might_like'),
                            onPressed:
                                () async {
                                  await EventLogger().logEvent(eventName: 'view_product_of_category',
                                  additionalData: {
                                    'category_name': category.name
                                  });
                                  Get.to(AllProducts(title: category.name,futureMethod: controller.getCategoryProducts(categoryId: category.id,),));
                    }

                    )
                    ,
                        const SizedBox(height: DSize.spaceBtwItem),
                        TGridLayout(
                            itemCount: products.length,
                            itemBuilder: (_, index) => TProductCardVertical(
                             product: products[index],
                            )
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ]);
  }
}
