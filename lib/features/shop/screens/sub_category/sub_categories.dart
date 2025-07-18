import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:app_my_app/common/widgets/appbar/appbar.dart';
import 'package:app_my_app/common/widgets/images/t_rounded_image.dart';
import 'package:app_my_app/common/widgets/products/product_cards/product_card_horizontal.dart';
import 'package:app_my_app/common/widgets/shimmer/horizontal_product_shimmer.dart';
import 'package:app_my_app/common/widgets/texts/section_heading.dart';
import 'package:app_my_app/features/shop/controllers/product/category_controller.dart';
import 'package:app_my_app/features/shop/models/category_model.dart';
import 'package:app_my_app/features/shop/screens/all_products/all_products.dart';
import 'package:app_my_app/utils/constants/image_strings.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/helper/cloud_helper_functions.dart';

import '../../../../utils/helper/event_logger.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({super.key, required this.category});
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    return Scaffold(
      appBar: TAppBar(
        title: Text(category.name,style:Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Column(
            children: [
              ///Banner
              const TRoundedImage(
                imageUrl: TImages.promoBanner2,
                width: double.infinity,
                height: null,
                applyImageRadius: true,
              ),
              const SizedBox(
                height: DSize.spaceBtwSection,
              ),
              //Sub categories
              FutureBuilder(
                future: controller.getSubCategories(category.id),
                builder: (context, snapshot) {
                 // handle loader no record error message
                  const loader = THorizontalProductShimmer();
                  final widget = TCloudHelperFunctions.checkMultiRecordState(
                      snapshot: snapshot, loader: loader);
                  if (widget != null) return widget;
                  final subCategories = snapshot.data!;

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: subCategories.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) {
                        final subCategory = subCategories[index];
                        return FutureBuilder(
                          future: controller.getCategoryProducts(
                              categoryId: subCategory.id),
                          builder: (context, snapshot) {
                            //handle loader no record error message
                            final widget =
                                TCloudHelperFunctions.checkMultiRecordState(
                                    snapshot: snapshot, loader: loader);
                            if (widget != null) return widget;
                            final products = snapshot.data!;
                            return Column(
                              children: [
                                TSectionHeading(
                                  title: subCategory.name,
                                  onPressed: () async{
                                    await EventLogger().logEvent(
                                        eventName: "sub_category_tracked",
                                        additionalData: {
                                          "category_name": subCategory.name,
                                        }
                                    );
                                    Get.to(() => AllProducts(
                                      title: subCategory.name,
                                      futureMethod:
                                      controller.getCategoryProducts(
                                        categoryId: subCategory.id,
                                      ),
                                    ));
                                  } ,
                                ),
                                const SizedBox(
                                  height: DSize.spaceBtwItem / 2,
                                ),
                                //TProductCardHorizontal(),
                                SizedBox(
                                  height: 120,
                                  child: ListView.separated(
                                    itemBuilder: (context, index) =>
                                        TProductCardHorizontal(product: products[index],),
                                    itemCount: products.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(
                                      width: DSize.spaceBtwItem,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                  ),
                                ),
                                const SizedBox(height: DSize.spaceBtwSection,)
                              ],
                            );
                          },
                        );
                      });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
