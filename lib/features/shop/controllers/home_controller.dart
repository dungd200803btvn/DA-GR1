import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../data/repositories/product/product_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/popups/loader.dart';
import '../models/product_model.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();
  final query = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Đăng ký lắng nghe thay đổi từ TextEditingController
    query.addListener(_searchProducts);
    loadAllProducts();
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

  final productRepository = Get.put(ProductRepository());
  final RxList<ProductModel> _allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  // Phương thức để tải tất cả sản phẩm từ Firestore và lưu trữ trong biến cục bộ
  Future<void> loadAllProducts() async {
    try {
      _allProducts.value = await productRepository.getAllProducts();
      // Khởi tạo danh sách lọc bằng tất cả sản phẩm
      filteredProducts.value = _allProducts.value;
    } catch (e) {
      TLoader.errorSnackbar(title: lang.translate('snap'), message: e.toString());
    }
  }

  // Phương thức để tìm kiếm sản phẩm theo query
  void _searchProducts() {
    String lowerCaseQuery = query.text.toLowerCase();
    filteredProducts.value = _allProducts.where((product) =>
        product.title.toLowerCase().contains(lowerCaseQuery)).toList();
  }

  @override
  void onClose() {
    query.removeListener(_searchProducts);
    super.onClose();
  }
}
