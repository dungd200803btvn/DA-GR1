import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_my_app/common/widgets/products/favourite_icon/favourite_icon.dart';
import 'package:app_my_app/features/shop/controllers/product/images_controller.dart';
import 'package:app_my_app/utils/helper/event_logger.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helper/helper_function.dart';
import '../../../models/product_model.dart';

class TProductImageSlider extends StatefulWidget {
  const TProductImageSlider({super.key, required this.product});
  final ProductModel product;

  @override
  State<TProductImageSlider> createState() => _TProductImageSliderState();
}

class _TProductImageSliderState extends State<TProductImageSlider> {
  late final ImagesController controller;
  late final bool dark;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ImagesController(), permanent: false);
    controller.initialize(widget.product);
  }

  @override
  void dispose() {
    Get.delete<ImagesController>(); // Cleanup controller nếu cần
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dark = DHelperFunctions.isDarkMode(context);

    return TCurvedEdgeWidget(
      child: Container(
        color: dark ? DColor.darkerGrey : DColor.light,
        child: Stack(
          children: [
            // 1.1 Main Larger Image
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                return Container(
                  height: 350,
                  width: maxWidth,
                  padding: EdgeInsets.all(DSize.productImageRadius / 2),
                  child: Center(
                    child: Obx(() {
                      final image = controller.selectedProductImage.value;
                      return GestureDetector(
                        onTap: () async {
                          await EventLogger().logEvent(
                            eventName: 'showEnlargedImage',
                            additionalData: {'product_id': widget.product.id},
                          );
                          controller.showEnlargedImage(image, context);
                        },
                        child: CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          width: maxWidth,
                          progressIndicatorBuilder: (_, __, downloadProgress) =>
                              CircularProgressIndicator(
                                value: downloadProgress.progress,
                                color: DColor.primary,
                              ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),

            // 1.2 Image Slider
            Positioned(
              right: 0,
              bottom: 40,
              left: DSize.defaultspace,
              child: Obx(() => SizedBox(
                height: 60,
                child: ListView.separated(
                  itemBuilder: (_, index) {
                    if (index < 0 || index >= controller.images.length) {
                      return const SizedBox.shrink();
                    }
                    return Obx(() => TRoundedImage(
                      isNetWorkImage: true,
                      onPressed: () {
                        controller.selectedProductImage.value =
                        controller.images[index];
                      },
                      imageUrl: controller.images[index],
                      width: 60,
                      backgroundColor:
                      dark ? DColor.dark : DColor.white,
                      border: Border.all(
                        color: controller.selectedProductImage.value ==
                            controller.images[index]
                            ? DColor.primary
                            : Colors.transparent,
                      ),
                      padding: const EdgeInsets.all(DSize.sm),
                    ));
                  },
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: DSize.spaceBtwItem),
                  itemCount: controller.images.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                ),
              )),
            ),

            // 1.3 Appbar Icon
            TAppBar(
              showBackArrow: true,
              actions: [
                TFavouriteIcon(productId: widget.product.id),
              ],
            )
          ],
        ),
      ),
    );
  }
}
