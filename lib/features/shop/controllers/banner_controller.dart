import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:t_store_app/data/repositories/banners/banner_repository.dart';
import 'package:t_store_app/features/shop/models/banner_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/popups/loader.dart';

class BannerController extends GetxController{
  static BannerController get instance => Get.find();
  //variables
  final carousalCurrentIndex = 0.obs;
  final isLoading = false.obs;
  RxList<BannerModel> banners = <BannerModel>[].obs;
  final bannerRepo = Get.put(BannerRepository());
  @override
  void onInit() {
    fetchBanners();
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
  //update page navigation dots
  void updatePageIndicator(index){
    carousalCurrentIndex.value  = index;
  }
  //bannerRepo.uploadDummyData(TDummyData.banners);
  //fetch banners
  Future<void> fetchBanners() async{
    try{
      isLoading.value = true;
      //fetch
      final banners = await bannerRepo.fetchBanners();
      this.banners.assignAll(banners);
    }catch(e){
      TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
    }finally{
      isLoading.value = false;
    }
  }
}
