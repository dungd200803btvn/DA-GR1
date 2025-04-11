import 'package:app_my_app/utils/popups/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../../data/repositories/product/product_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../models/product_model.dart';

class AllProductController extends GetxController {
  static AllProductController get instance => Get.find();
// Số lượng sản phẩm đang hiển thị
  RxInt visibleCount = 20.obs;
  // Computed property: danh sách sản phẩm hiển thị
  RxList<ProductModel> products = <ProductModel>[].obs;
  List<ProductModel> get displayedProducts =>
      products.take(visibleCount.value).toList();
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  String? nextPageToken; // Token phân trang (ví dụ: timestamp ISO)
  // Sử dụng để lưu lại thông tin filter đang dùng
  late String filterType; // 'category', 'brand', hoặc 'shop'
  late String filterId;
  final ProductRepository productRepository = ProductRepository.instance;
  /// Lấy danh sách sản phẩm dựa trên loại filter và id tương ứng
  Future<void> fetchProducts({
    required String filterType,
    required String filterId,
  }) async {
    isLoading.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TFullScreenLoader.openLoadingDialog('Loading products now...', TImages.loaderAnimation);
    });
    this.filterType = filterType;
    this.filterId = filterId;
    products.clear();
    try {
      final result = await productRepository.getProducts(
        categoryId: filterType == 'category' ? filterId : null,
        brandId: filterType == 'brand' ? filterId : null,
        shopId: filterType == 'shop' ? filterId : null,
      );
      products.value = result;
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TFullScreenLoader.stopLoading();
      });
    }
  }
  /// Hàm load thêm dữ liệu (phân trang)
  void loadMoreProducts(){
    if (visibleCount.value < products.length) {
      visibleCount.value += 20;
      if (visibleCount.value > products.length) {
        visibleCount.value = products.length;
      }
    } else {
      TLoader.warningSnackbar(title: 'Đã xem hết sản phẩm');
    }
  }
}
