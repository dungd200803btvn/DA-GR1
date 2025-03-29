import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/features/shop/models/product_model.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helper/helper_function.dart';

class ImagesController extends GetxController {
  static ImagesController get instance => Get.find();
  //variables
  RxString selectedProductImage = ''.obs;
// List of all product images
  late RxList<String> images = <String>[].obs;
  late AppLocalizations lang;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }
  // Initialize the controller with product data
  void initialize(ProductModel productModel) {
    // Reset the selected image and image list
    selectedProductImage.value = productModel.images![0];
    images.clear();
    // Add thumbnail and other unique images
    Set<String> uniqueImages = {productModel.images![0]};
    if (productModel.images != null) {
      uniqueImages.addAll(productModel.images!);
    }
    images.addAll(uniqueImages);
  }

//show image popup
  void showEnlargedImage(String image, BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
   final  color =  dark ? DColor.white : DColor.white;
    Get.to(
      fullscreenDialog: true,
          () => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: color,
          body: Stack(
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.contain, // hoặc BoxFit.cover nếu bạn muốn crop hình
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 150,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text(lang.translate('close')),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
