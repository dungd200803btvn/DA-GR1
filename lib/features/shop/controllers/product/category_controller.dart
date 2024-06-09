import 'package:get/get.dart';
import 'package:t_store/data/repositories/categories/category_repository.dart';
import 'package:t_store/utils/popups/loader.dart';
import '../../../../data/repositories/product/product_repository.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();
  final isLoading = false.obs;
  final _categoryRepository = Get.put(CategoryRepository());
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // _categoryRepository.uploadDummyData(TDummyData.categories);
    fetchCategories();
  }

  /// Load category data
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final categories = await _categoryRepository.getAllCategories();
      //update new data
      allCategories.assignAll(categories);
      //filter
      featuredCategories.assignAll(allCategories
          .where((category) => category.isFeatured && category.parentId.isEmpty)
          .take(8)
          .toList());
      } catch (e) {
        TLoader.errorSnackbar(title: 'Oh Snap', message: e.toString());
        print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Load selected category data

  /// Get category products
  Future<List<ProductModel>> getCategoryProducts(
      {required String categoryId, int limit = 10}) async {
    try {
      final products = await ProductRepository.instance
          .getProductsForCategory(categoryId: categoryId, limit: limit);
      return products;
    } catch (e) {
      TLoader.errorSnackbar(title: 'Oh Snap!', message: e.toString());
      print(e.toString());
      return [];
    }
  }

  Future<List<CategoryModel>> getSubCategories(String categoryId) async{
    try{
      final subCategories = await _categoryRepository.getSubCategories(categoryId);
      return  subCategories;
    }catch (e) {
      TLoader.errorSnackbar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }
}
