import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_app/features/shop/controllers/product/favourite_controller.dart';
import 'package:my_app/utils/constants/colors.dart';
import '../../../../utils/helper/event_logger.dart';
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
        onPressed: () async{
          await EventLogger().logEvent(
              eventName: "favourite_product",
              additionalData: {
                "product_id": productId,
              }
          );
          controller.toggleFavouriteProduct(productId);
        } ,
      ),
    );
  }
}
