import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/common/widgets/products/favourite_icon/favourite_icon.dart';
import 'package:my_app/features/shop/controllers/product/images_controller.dart';
import 'package:my_app/utils/helper/event_logger.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helper/helper_function.dart';
import '../../../models/product_model.dart';

class TProductImageSlider extends StatelessWidget {
  const TProductImageSlider({
    super.key,
    required this.product,
  });
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller = Get.put(ImagesController());
    controller.initialize(product);

    return TCurvedEdgeWidget(
      child: Container(
        color: dark ? DColor.darkerGrey : DColor.light,
        child: Stack(
          children: [
            //1.1 Main Larger Image
            LayoutBuilder(
              builder: (context, constraints) {
                // Lấy chiều rộng của widget cha
                final maxWidth = constraints.maxWidth;
                // Tùy chọn: sử dụng AspectRatio nếu bạn muốn giữ tỷ lệ (ví dụ 16:9)
                return Container(
                  height: 350,
                  width: maxWidth,
                  padding: EdgeInsets.all(DSize.productImageRadius/2),
                  child: Center(
                    child: Obx(() {
                      final image = controller.selectedProductImage.value;
                      return GestureDetector(
                        onTap: () async {
                          await EventLogger().logEvent(
                            eventName: 'showEnlargedImage',
                            additionalData: {'product_id': product.id},
                          );
                          controller.showEnlargedImage(image,context);
                        },
                        child: CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          width: maxWidth, // đảm bảo chiếm hết chiều rộng của cha
                          progressIndicatorBuilder: (_, __, downloadProgress) =>
                              CircularProgressIndicator(
                                value: downloadProgress.progress,
                                color: DColor.primary,
                              ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),

            //1.2 Image Slider
            Positioned(
              right: 0,
              bottom: 40,
              left: DSize.defaultspace,
              child: Obx(() => SizedBox(
                height: 60,
                child: ListView.separated(
                  itemBuilder: (_, index) {
                    if (index < 0 || index >=  controller.images.length) {
                      return const SizedBox.shrink();
                    }
                    return Obx(()=>
                       TRoundedImage(
                        isNetWorkImage: true,
                        onPressed: () {
                          controller.selectedProductImage.value = controller.images[index];
                        },
                        imageUrl: controller.images[index],
                        width: 60,
                        backgroundColor: dark ? DColor.dark : DColor.white,
                        border: Border.all(
                          color: controller.selectedProductImage.value == controller.images[index] ? DColor.primary : Colors.transparent,
                        ),
                        padding: const EdgeInsets.all(DSize.sm),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: DSize.spaceBtwItem),
                  itemCount: controller.images.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                ),
              ))
              ,
            ),
            //1.3 Appbar Icon
            TAppBar(
              showBackArrow: true,
              actions: [
                TFavouriteIcon(productId: product.id,)
              ],
            )
          ],
        ),
      ),
    );
  }
}
