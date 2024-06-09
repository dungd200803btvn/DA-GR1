import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/shop/controllers/product/favourite_controller.dart';
import 'package:t_store/utils/constants/colors.dart';
import '../../icons/t_circular_icon.dart';

class TFavouriteIcon extends StatelessWidget {
  const TFavouriteIcon({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavouritesController());
    return Obx(
      () => TCircularIcon(
        icon:
            controller.isFavourite(productId) ? Iconsax.heart5 : Iconsax.heart,
        color: controller.isFavourite(productId) ? DColor.error : null,
        onPressed: () => controller.toggleFavouriteProduct(productId),
      ),
    );
  }
}
