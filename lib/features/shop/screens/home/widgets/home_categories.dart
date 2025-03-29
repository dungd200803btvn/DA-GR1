import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/common/widgets/shimmer/category_shimmer.dart';
import 'package:lcd_ecommerce_app/features/shop/controllers/product/category_controller.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/all_products/all_product_screen.dart';
import 'package:lcd_ecommerce_app/features/shop/screens/sub_category/sub_categories.dart';
import 'package:lcd_ecommerce_app/utils/helper/event_logger.dart';
import '../../../../../common/widgets/image_text_widgets/vertical_image_text.dart';
import '../../../../../utils/constants/sizes.dart';
class THomeCategories extends StatelessWidget {
  const THomeCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());
    return Obx(
          () => SizedBox(
        height: 105,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: categoryController.featuredCategories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            final category = categoryController.featuredCategories[index];
            return TVerticalImageText(
              title: category.name,
              onTap: () async{
                await EventLogger().logEvent(
                    eventName: "category_tracked",
                    additionalData: {
                      "category_name": category.name,
                  }
                );
                Get.to(() => AllProductScreen(title: category.name, filterId: category.id, filterType: 'category',));
              }, url: category.image ,
            );
          },
          separatorBuilder: (_, index) => const SizedBox(width: DSize.spaceBtwItem/3), // Use DSize.spaceBtwItem as separator
        ),
      ),
    );
  }

}