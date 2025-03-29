import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/data/repositories/product/product_repository.dart';
import 'package:lcd_ecommerce_app/data/repositories/shop/shop_repository.dart';
import '../../models/shop_model.dart';

class ShopController extends GetxController{
  static ShopController get instance => Get.find();
  final RxList<ShopModel> featureShops = <ShopModel>[].obs;
  final RxList<ShopModel> allShops = <ShopModel>[].obs;
  RxBool isLoading = true.obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getFeatureShops();
  }
  final shopRepository  = ShopRepository.instance;
  final productRepository  = ProductRepository.instance;
  Future<void> getFeatureShops() async{
    try{
      isLoading.value = true;
      final shops = await shopRepository.fetchTopShops(limit: 10);
      final shops1 = await shopRepository.fetchTopShops(limit: 50);
      featureShops.assignAll(shops);
      allShops.assignAll(shops1);
    }catch(e){
      print('getFeaturedBrands(): loi: $e');
    }finally{
      isLoading.value = false;
    }
  }
}
