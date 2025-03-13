import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:t_store/data/repositories/product/product_repository.dart';
import 'package:t_store/features/shop/models/product_attribute_model.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/utils/enum/enum.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/formatter/formatter.dart';
import '../../../utils/popups/loader.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../suggestion/suggestion_repository.dart';
import '../models/brand_model.dart';
import '../models/product_variation_model.dart';
class ProductController extends GetxController {
  static ProductController get instance => Get.find();
  final isLoading = false.obs;
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final productRepository = Get.put(ProductRepository());
  final suggestionRepository = Get.put(ProductSuggestionRepository());
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
      return DFormatter.formattedAmount(product.price*24500);
    }
    else if (product.productType == ProductType.single.toString() && saleParcentage!=null ) {
      final discountedPrice = product.price * (1 - saleParcentage);
      return DFormatter.formattedAmount(discountedPrice*24500);
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
        return DFormatter.formattedAmount(largestPrice*24500);
      } else {
        return '${DFormatter.formattedAmount(smallestPrice*24500)}  - ${DFormatter.formattedAmount(largestPrice*24500)}';
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


  Future<List<ProductModel>> readProductsFromJson(String filePath) async {
    // Đọc dữ liệu từ file JSON
    final jsonString = await getFileData(filePath);
    final List<dynamic> jsonResponse = json.decode(jsonString);

    // Giới hạn số lượng đối tượng đọc từ JSON
    final limitedJsonResponse = jsonResponse.take(200).toList();

    // Danh sách các màu
    List<String> colors = ['Green', 'Black', 'Red', 'Blue', 'Yellow'];

    // Chuyển đổi JSON thành danh sách các đối tượng ProductModel
    return limitedJsonResponse.map((product) {
    List<String> images =   product['image_urls'] != null ? List<String>.from(product['image_urls']) : [];
    List<String> defaultSizes = ['EU 30','EU 32','EU 34','EU 36','EU 38'];


      // Tạo danh sách các giá trị cho thuộc tính 'Size'
      List<String> availableSizes = product['available_sizes'] != null ? List<String>.from(product['available_sizes'].length>=5 ? product['available_sizes'].map((size) => 'EU $size' as String): defaultSizes) : defaultSizes;

      // Tạo đối tượng ProductAttributeModel cho 'Size'
      ProductAttributeModel sizeAttribute = ProductAttributeModel(name: 'Size', values: availableSizes);

      // Tạo đối tượng ProductAttributeModel cho 'Color'
      ProductAttributeModel colorAttribute = ProductAttributeModel(name: 'Color', values: colors);

      // Tạo danh sách các biến thể sản phẩm với màu và size tương ứng
      List<ProductVariationModel> productVariations = [];
      if (product['variants'] != null) {
        for (String color in colors) {
          for (String size in availableSizes) {
            String sku = product['sku'] ;  // Thay bằng logic sinh SKU của bạn
            productVariations.add(ProductVariationModel(
              id: sku,
              stock: generateRandomId(), // Assuming `in_stock` is a boolean
              price: generatePrice().roundToDouble(), // Giá trị mặc định, bạn có thể thay đổi theo yêu cầu
              salePrice: (generatePrice() * 0.85).roundToDouble(), // Giá trị mặc định, bạn có thể thay đổi theo yêu cầu
              image: images[0] , // Assuming `image` field exists
              description: 'The product has good quality and reasonable price, it is worth trying once', // Mô tả mặc định, bạn có thể thay đổi theo yêu cầu
              attributeValues: {'Color': color, 'Size': size},
            ));
          }
        }
      }
    double price  = generatePrice().roundToDouble();
      return ProductModel(
        id: product['objectID'] ?? '',
        stock: generateRandomId(),
        sku: product['sku'] ?? '',
        price:  price ,
        title: product['name'] ?? '',
        date: product['created_at'] != null ? DateTime.fromMillisecondsSinceEpoch(product['created_at']) : null,
        salePrice: (price*0.7).roundToDouble() ,
        thumbnail: product['image_urls'] != null && product['image_urls'].isNotEmpty ? product['image_urls'][0] : '',
        isFeatured: true, // Assuming this is not provided in your JSON
        brand: product['brand'] != null ? BrandModel(name: product['brand'], id:(1+ Random().nextInt(14)).toString(), image: images[0],isFeatured: true,productsCount: generateRandomId()) : null,
        description: 'The product has good quality and reasonable price, it is worth trying once',
        categoryId:  (1+ Random().nextInt(16)).toString(),
        images: product['image_urls'] != null ? List<String>.from(product['image_urls']) : [],
        productType: ProductType.variable.toString(),
        productAttributes: [sizeAttribute, colorAttribute],
        productVariations: productVariations,
      );
    }).toList();
  }

}

