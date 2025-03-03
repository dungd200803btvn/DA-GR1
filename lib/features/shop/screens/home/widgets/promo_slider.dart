import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/shimmer/shimmer.dart';
import 'package:t_store/features/shop/controllers/banner_controller.dart';
import 'package:t_store/l10n/app_localizations.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/circular_container.dart';

class TPromoSlider extends StatelessWidget {
  const TPromoSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BannerController());
    final lang = AppLocalizations.of(context);
    return Obx(() {
      // Loading state
      if (controller.isLoading.value) {
        return const TShimmerEffect(width: double.infinity, height: 190);
      }

      // No data found state
      if (controller.banners.isEmpty) {
        return Center(child: Text(lang.translate('no_data_found')));
      }

      final banners = controller.banners;
      // Data found state
      return Column(
        children: [
          CarouselSlider(
            items: banners.map((banner) {
              return SizedBox(
                width: double.infinity,
                height: 220, // Set a fixed height for the image container
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DSize.borderRadiusMd),
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    errorWidget: (context, url, error) => Image.asset(
                      TImages.promoBanner3, // Replace with your error image path
                      fit: BoxFit.cover,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 220, // Set a fixed height for the carousel
              viewportFraction: 1,
              onPageChanged: (index, _) => controller.updatePageIndicator(index),
              autoPlay: true, // Enable autoplay
              autoPlayInterval: const Duration(seconds: 2,microseconds: 500), // Set autoplay interval
            ),
          ),
          const SizedBox(height: DSize.spaceBtwItem),
          Center(
            child: Obx(
                  () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < min(4, controller.banners.length); i++)
                    TCircularContainer(
                      width: 8, // Increase the size for better visibility
                      height: 8, // Increase the size for better visibility
                      backgroundColor: controller.carousalCurrentIndex.value == i
                          ? DColor.primary
                          : DColor.grey,
                      margin: const EdgeInsets.only(right: 10),
                    ),
                ],
              ),
            ),
          )
        ],
      );
    });
  }
}
