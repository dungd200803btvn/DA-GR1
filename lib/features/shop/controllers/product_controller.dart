import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_app/data/repositories/product/product_repository.dart';
import 'package:my_app/features/shop/models/product_model.dart';
import 'package:my_app/utils/enum/enum.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/formatter/formatter.dart';
import '../../../utils/popups/loader.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../suggestion/suggestion_repository.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  DocumentSnapshot? lastFeaturedDoc;
  final productRepository = ProductRepository.instance;
  final suggestionRepository = ProductSuggestionRepository.instance;
  @override
  void onInit() {
    fetchFeaturedProducts();
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

  // Load trang đầu tiên (hoặc load cache nếu có)
  void fetchFeaturedProductsPage() async {
    print("=== fetchFeaturedProductsPage() START ===");
    try {
      isLoading.value = true;
      Map<String, dynamic> result = await productRepository.getFeaturedProductsPage();
      print(">> fetchFeaturedProductsPage() - result: $result");

      // Kiểm tra xem dữ liệu products trả về là JSON hay đã là ProductModel
      if (result['products'] is List<dynamic> && result['products'].isNotEmpty) {
        // Kiểm tra phần tử đầu tiên, nếu nó Map thì cần parse, nếu đã là ProductModel thì có thể sử dụng luôn.
        var first = result['products'][0];
        print("Du lieu images: ${first['Images']}");
        if (first is Map) {
          print(">> Dữ liệu products trả về ở dạng JSON, bắt đầu parse thành ProductModel...");
          List<ProductModel> fetchedProducts = await Future.wait(
              (result['products'] as List<dynamic>).map((json) async {
                final product = await ProductModel.toModelFromJson(json);
                print(">> Parse product từ JSON: ${product.images![0]}");
                return product;
              })
          );
          fetchedProducts.forEach((product) => print(">> Sản phẩm: ${product.images![0]}"));
          lastFeaturedDoc = result['lastDoc'];
          featuredProducts.assignAll(fetchedProducts);
        }
        else if (first is ProductModel) {
          print(">> Dữ liệu products trả về đã là ProductModel");
          List<ProductModel> fetchedProducts = result['products'] as List<ProductModel>;
          fetchedProducts.forEach((product) => print(">> Sản phẩm: ${product.images![0]}"));
          lastFeaturedDoc = result['lastDoc'];
          featuredProducts.assignAll(fetchedProducts);
        } else {
          print(">> Kiểu dữ liệu không xác định cho products: ${first.runtimeType}");
        }
      } else {
        print(">> Không có sản phẩm nào được trả về");
      }
    } catch (e) {
      print("Error in fetchFeaturedProducts: $e");
    } finally {
      isLoading.value = false;
      print("=== fetchFeaturedProductsPage() END ===");
    }
  }


  // Tải thêm sản phẩm (infinite scroll hoặc khi nhấn "Xem thêm")
  void loadMoreFeaturedProducts() async {
    print("=== loadMoreFeaturedProducts() START ===");
    if (isLoadingMore.value) {
      print(">> loadMoreFeaturedProducts(): isLoadingMore is true, returning early.");
      return;
    }
    try {
      isLoadingMore.value = true;
      Map<String, dynamic> result = await productRepository.getFeaturedProductsPage(lastDoc: lastFeaturedDoc);
      print(">> loadMoreFeaturedProducts() - result: $result");

      List<ProductModel> fetchedProducts;
      // Kiểm tra xem danh sách trả về có rỗng không
      if (result['products'] is List && (result['products'] as List).isNotEmpty) {
        var firstElement = (result['products'] as List)[0];
        // Nếu dữ liệu trả về ở dạng JSON (Map) -> parse thành ProductModel
        if (firstElement is Map) {
          print(">> Dữ liệu products trả về ở dạng JSON, bắt đầu parse thành ProductModel...");
             fetchedProducts = await Future.wait(
              (result['products'] as List<dynamic>).map((json) async {
                final product = await ProductModel.toModelFromJson(json);
                print(">> Parse product từ JSON: ${product.images![0]}");
                return product;
              })
          );
          fetchedProducts.forEach((product) => print(">> Sản phẩm: ${product.images![0]}"));
        }
        // Nếu dữ liệu đã ở dạng ProductModel
        else if (firstElement is ProductModel) {
          print(">> loadMoreFeaturedProducts(): products returned as ProductModel.");
          fetchedProducts = fetchedProducts = result['products'] as List<ProductModel>;
        }
        else {
          print(">> loadMoreFeaturedProducts(): Unknown product data type: ${firstElement.runtimeType}");
          fetchedProducts = [];
        }
      } else {
        print(">> loadMoreFeaturedProducts(): No products returned.");
        fetchedProducts = [];
      }

      lastFeaturedDoc = result['lastDoc'];
      print(">> loadMoreFeaturedProducts(): Fetched products count: ${fetchedProducts.length}");
      featuredProducts.addAll(fetchedProducts);
      print(">> loadMoreFeaturedProducts(): Total featuredProducts count: ${featuredProducts.length}");
    } catch (e) {
      print("Error in loadMoreFeaturedProducts: $e");
    } finally {
      isLoadingMore.value = false;
      print("=== loadMoreFeaturedProducts() END ===");
    }
  }


  void fetchFeaturedProducts() async {
    try {
      isLoading.value = true;
      //fetch products
      final products = await productRepository.getFeaturedProducts();
      final products1 = await productRepository.getAllProducts();
      //assign products
      featuredProducts.assignAll(products);
      allProducts.assignAll(products1);
    } catch (e) {
      TLoader.errorSnackbar(title: lang.translate('snap'), message: e.toString());
      if (kDebugMode) {
        print("error in fetchFeaturedProducts() : $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProductModel>> getAllFeaturedProducts() async{
     try{
      return await productRepository.getAllProducts();
    }catch(e){
     TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
      return [];
    }
  }

  Future<List<ProductModel>> getSuggestedProductsById(String productId) async{
    try{
      final sortedSuggestions = await suggestionRepository.getSortedSuggestions(productId);
      final productIds = sortedSuggestions.map((e) => e.productId).toList();
      final products = await productRepository.getProductsByIds(productIds);
      return products;
    }catch(e){
      TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
      return [];
    }
  }

  String getProductPrice(ProductModel product, [double? saleParcentage]) {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;
    //if no variations exist, return simple price or sale price
    if(saleParcentage==null && product.productType == ProductType.single.toString()){
      return DFormatter.formattedAmount(product.price);
    }
    else if (product.productType == ProductType.single.toString() && saleParcentage!=null ) {
      final discountedPrice = product.price * (1 - saleParcentage);
      return DFormatter.formattedAmount(discountedPrice);
    } else {
      //calculate max and min price
      for (var variation in product.productVariations!) {
        double priceToConsider;
        if(saleParcentage!=null){
          priceToConsider  =  variation.price * (1 - saleParcentage);
        }else{
          priceToConsider  = variation.price;
        }
        //update min max
        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }
        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }
      if (smallestPrice.isEqual(largestPrice)) {
        // return largestPrice.toStringAsFixed(1);
        return DFormatter.formattedAmount(largestPrice);
      } else {
        return '${DFormatter.formattedAmount(smallestPrice)}  - ${DFormatter.formattedAmount(largestPrice)}';
      }
    }
  }

  String? calculateSalePercentage([double? salePercentage]) {
    if (salePercentage == null ) {
      return null;
    }
    double percentage = salePercentage * 100;
    return percentage.toStringAsFixed(0);
  }

  String getProductStockStatus(int stock) {
    return stock > 0 ? lang.translate('in_stock') : lang.translate('out_stock');
  }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }
  int generateRandomId() {
    final random = Random();
    return 100 + random.nextInt(901); // Từ 100 đến 1000
  }
  double generatePrice(){
    return 10+ Random().nextDouble()*1000;
  }
  T getRandomElement<T>(List<T> list) {
    final random = Random();
    return list[random.nextInt(list.length)];
  }
}

