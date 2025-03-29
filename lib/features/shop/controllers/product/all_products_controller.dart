import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:t_store_app/data/repositories/product/product_repository.dart';
import 'package:t_store_app/features/shop/models/product_model.dart';
import 'package:t_store_app/utils/popups/loader.dart';
import '../../../../common/widgets/products/sortable/sort_option.dart';
import '../../../../l10n/app_localizations.dart';

class AllProductsController extends GetxController{
  static AllProductsController get instance => Get.find();
  final repository = ProductRepository.instance;
  final Rx<SortOption> selectedSortOption = SortOption.name.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  late AppLocalizations lang;
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }
  Future<List<ProductModel>> fetchProductsByQuery(Query? query) async{
    try{
      if(query==null) return [];
      final products =await repository.fetchProductsByQuery(query);
      return products;
    }catch(e){
      TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
      return [];
    }
  }
  void sortProducts(SortOption option, BuildContext context) {
    selectedSortOption.value = option;
    switch (option) {
      case SortOption.name:
        products.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.higherPrice:
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.lowerPrice:
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.newest:
        products.sort((a, b) => a.createAt.compareTo(b.createAt));
        break;
      case SortOption.sale:
        break;
      case SortOption.popularity:
        products.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
  }
  void assignProducts(List<ProductModel> products,BuildContext context){
    this.products.assignAll(products);
    sortProducts(SortOption.name,context);
  }
}
