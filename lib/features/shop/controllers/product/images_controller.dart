import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/utils/constants/sizes.dart';

import '../../../../l10n/app_localizations.dart';

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
    selectedProductImage.value = productModel.thumbnail;
    images.clear();
    // Add thumbnail and other unique images
    Set<String> uniqueImages = {productModel.thumbnail};
    if (productModel.images != null) {
      uniqueImages.addAll(productModel.images!);
    }
    images.addAll(uniqueImages);
  }


//show image popup
  void showEnlargedImage(String image) {
    Get.to(
      fullscreenDialog: true,
        () => Dialog.fullscreen(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: DSize.defaultspace*2,horizontal: DSize.defaultspace),
                child: CachedNetworkImage(imageUrl: image,),),
                const SizedBox(height: DSize.spaceBtwSection,),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 150,
                    child: OutlinedButton(onPressed: ()=> Get.back(),child: Text(lang.translate('close')),),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
