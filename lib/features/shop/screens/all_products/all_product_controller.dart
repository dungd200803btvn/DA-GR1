import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../../data/repositories/product/product_repository.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../models/product_model.dart';

// class AllProductController extends GetxController {
//   static AllProductController get instance => Get.find();
//   RxList<ProductModel> products = <ProductModel>[].obs;
//   RxBool isLoading = false.obs;
//   RxBool isLoadingMore = false.obs;
//   String? nextPageToken; // Lưu token phân trang (ví dụ timestamp ISO)
//   late String categoryId;
//
//   final ProductRepository productRepository = ProductRepository.instance;
//
//   // Gọi API lần đầu để lấy danh sách sản phẩm
//   Future<void> fetchProductsByCategory(String categoryId) async {
//     this.categoryId = categoryId;
//     products.clear();
//     isLoading.value = true;
//     try {
//       final result = await productRepository.getProductsByCategory(categoryId, limit: limit);
//       // Giả sử kết quả JSON có key 'products' và 'nextPageToken'
//       final List<dynamic> productJsonList = result['products'];
//       print("du lieu json: ${result}");
//       nextPageToken = result['nextPageToken'];
//       print("du lieu json: nextPageToken: ${nextPageToken}");
//       List<ProductModel> fetchedProducts = await Future.wait(
//           productJsonList.map((json) => ProductModel.toModelFromJson(json)).toList()
//       );
//       fetchedProducts.map((product)=> {
//         print('Thong tin cac san pham: ${product.toJson()}\n')
//       });
//       products.value = fetchedProducts;
//     } catch (e) {
//       print("Error fetching products: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Hàm load thêm dữ liệu khi người dùng nhấn nút "Xem thêm"
//   Future<void> loadMoreProducts() async {
//     if (isLoadingMore.value || nextPageToken == null) return;
//     isLoadingMore.value = true;
//     try {
//       final result = await productRepository.getProductsByCategory(categoryId,
//           limit: limit, startAfter: nextPageToken);
//       final List<dynamic> productJsonList = result['products'];
//       nextPageToken = result['nextPageToken'];
//       List<ProductModel> fetchedProducts = await Future.wait(
//           productJsonList.map((json) => ProductModel.toModelFromJson(json)).toList()
//       );
//       products.addAll(fetchedProducts);
//     } catch (e) {
//       print("Error loading more products: $e");
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }
// }
//

class AllProductController extends GetxController {
  static AllProductController get instance => Get.find();

  RxList<ProductModel> products = <ProductModel>[].obs;
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
    this.filterType = filterType;
    this.filterId = filterId;
    products.clear();
    isLoading.value = true;
    try {
      final result = await productRepository.getProducts(
        categoryId: filterType == 'category' ? filterId : null,
        brandId: filterType == 'brand' ? filterId : null,
        shopId: filterType == 'shop' ? filterId : null,
        limit: limit,
      );
      // Giả sử JSON trả về có key 'products' và 'nextPageToken'
      final List<dynamic> productJsonList = result['products'];
      nextPageToken = result['nextPageToken'];

      List<ProductModel> fetchedProducts = await Future.wait(
        productJsonList.map((json) => ProductModel.toModelFromJson(json)).toList(),
      );
      products.value = fetchedProducts;
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Hàm load thêm dữ liệu (phân trang)
  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value || nextPageToken == null) return;
    isLoadingMore.value = true;

    try {
      final result = await productRepository.getProducts(
        categoryId: filterType == 'category' ? filterId : null,
        brandId: filterType == 'brand' ? filterId : null,
        shopId: filterType == 'shop' ? filterId : null,
        limit: limit,
        startAfter: nextPageToken,
      );
      final List<dynamic> productJsonList = result['products'];
      nextPageToken = result['nextPageToken'];
      List<ProductModel> fetchedProducts = await Future.wait(
        productJsonList.map((json) => ProductModel.toModelFromJson(json)).toList(),
      );
      products.addAll(fetchedProducts);
    } catch (e) {
      print("Error loading more products: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }
}

