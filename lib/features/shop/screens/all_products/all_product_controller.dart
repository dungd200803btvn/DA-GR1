import 'package:cloud_firestore/cloud_firestore.dart';
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
  // Computed property: danh sách sản phẩm hiển thị
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxInt visibleCount = 20.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  DocumentSnapshot? lastDocument; // 🔥 để phân trang
  RxBool hasMore = true.obs; // Token phân trang (ví dụ: timestamp ISO)
  // Sử dụng để lưu lại thông tin filter đang dùng
  late String filterType; // 'category', 'brand', hoặc 'shop'
  late String filterId;
  List<ProductModel> get displayedProducts => products.toList();
  final ProductRepository productRepository = ProductRepository.instance;
  /// Lấy danh sách sản phẩm dựa trên loại filter và id tương ứng
  Future<void> fetchProducts({
    required String filterType,
    required String filterId,
  }) async {
    final startTime = DateTime.now();
    isLoading.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TFullScreenLoader.openLoadingDialog('Loading products now...', TImages.loaderAnimation);
    });
    this.filterType = filterType;
    this.filterId = filterId;
    products.clear();
    lastDocument = null;
    hasMore = true.obs;
    try {
      final result = await productRepository.getProducts(
        categoryId: filterType == 'category' ? filterId : null,
        brandId: filterType == 'brand' ? filterId : null,
        shopId: filterType == 'shop' ? filterId : null,
        limit: 20,
        startAfterDoc: lastDocument,
      );
      if(result.isNotEmpty){
        lastDocument = result.last.snapshot;
        products.addAll(result);
      }else{
        hasMore=false.obs;
      }
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("🔥 Thời gian tải sản phẩm: ${duration.inMilliseconds}ms");
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
  Future<void> loadMoreProducts() async {
    final startTime = DateTime.now();
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;

    try {
      final newProducts = await productRepository.getProducts(
        categoryId: filterType == 'category' ? filterId : null,
        brandId: filterType == 'brand' ? filterId : null,
        shopId: filterType == 'shop' ? filterId : null,
        limit: 20,
        startAfterDoc: lastDocument,
      );

      if (newProducts.isNotEmpty) {
        lastDocument = newProducts.last.snapshot;
        products.addAll(newProducts);
      } else {
        hasMore = false.obs;
      }
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("🔥 Thời gian tải 20 sản phẩm tiếp theo: ${duration.inMilliseconds}ms");
    } catch (e) {
      print("Error loading more: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }
}
