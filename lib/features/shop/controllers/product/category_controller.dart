import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:app_my_app/data/repositories/categories/category_repository.dart';
import 'package:app_my_app/utils/popups/loader.dart';
import '../../../../data/repositories/product/product_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();
  final isLoading = false.obs;
  final _categoryRepository = Get.put(CategoryRepository());
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;
  late AppLocalizations lang;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // _categoryRepository.uploadDummyData(TDummyData.categories);
    fetchCategories();
  }
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }

  /// Load category data
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final categories = await _categoryRepository.fetchTopCategories();
      //update new data
      allCategories.assignAll(categories);
      //filter
      featuredCategories.assignAll(allCategories
          .toList());
      } catch (e) {
        print('Loi o: fetchCategories() in controller: $e ');
        TLoader.errorSnackbar(title: lang.translate('snap'), message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Load selected category data

  /// Get category products
  Future<List<ProductModel>> getCategoryProducts({required String categoryId}) async {
    try {
      final products = await ProductRepository.instance
          .getProductsForCategory1(categoryId: categoryId);
      return products;
    } catch (e) {
     TLoader.errorSnackbar(title: lang.translate('snap'), message: e.toString());
      return [];
    }
  }

  Future<List<CategoryModel>> getSubCategories(String categoryId) async{
    try{
      final subCategories = await _categoryRepository.getSubCategories(categoryId);
      subCategories.forEach((element) {
      });
      return  subCategories;
    }catch (e) {
      TLoader.errorSnackbar(title: lang.translate('snap'), message: e.toString());
      return [];
    }
  }
}
