import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:t_store/data/repositories/brands/brand_repository.dart';
import 'package:t_store/data/repositories/product/product_repository.dart';
import 'package:t_store/features/shop/models/brand_model.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/utils/popups/loader.dart';

import '../../../l10n/app_localizations.dart';

class BrandController extends GetxController{
  static BrandController get instance => Get.find();
  RxBool isLoading = true.obs;
  final RxList<BrandModel> allBrands = <BrandModel>[].obs;
  final RxList<BrandModel> featuredBrands = <BrandModel>[].obs;
  final brandRepository  = Get.put(BrandRepository());
  final productRepository  = Get.put(ProductRepository());
  @override
  void onInit() {
   // brandRepository.uploadBrandCategoryData(TDummyData.brandCategorys);
   // productRepository.uploadProductCategoryData(TDummyData.productCategorys);
    getFeaturedBrands();
    super.onInit();
  }
  late AppLocalizations lang;
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }
  Future<void> getFeaturedBrands() async{
    try{
      isLoading.value = true;
      final brands = await brandRepository.getAllBrands();
      allBrands.assignAll(brands);
      featuredBrands.assignAll(allBrands.where((brand) => brand.isFeatured== false).take(6));
    }catch(e){
      TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
    }finally{
      isLoading.value = false;
    }
  }

  //get products of a brand
Future<List<ProductModel>> getBrandProducts({required String brandId,int limit=-1 }) async{
    try{
      final products = await ProductRepository.instance.getProductsForBrand( brandId: brandId,limit: limit);
      return products;
    }
    catch(e){
      TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
}

//get brands for category
Future<List<BrandModel>> getBrandsForCategory(String categoryId) async{
    try{
      final brands = await brandRepository.getBrandsForCategory(categoryId);
      return brands;
    }catch(e){
      TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
}

}
