import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_my_app/data/repositories/brands/brand_repository.dart';
import 'package:app_my_app/data/repositories/categories/category_repository.dart';
import 'package:app_my_app/data/repositories/shop/shop_repository.dart';
import 'package:app_my_app/features/shop/models/brand_model.dart';
import 'package:app_my_app/features/shop/models/category_model.dart';
import 'package:app_my_app/features/shop/models/product_attribute_model.dart';
import 'package:app_my_app/features/shop/models/product_variation_model.dart';
import 'package:app_my_app/features/shop/models/shop_model.dart';

class ProductModel {
  String id;
  int stock;
  double price;
  String title;
  DateTime createAt;
  bool? isFeatured;
  BrandModel? brand;
  ShopModel shop;
  String? description;
  Map<String, String>? details;
  List<CategoryModel>? categories;
  List<String>? images;
  String productType;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;

  ProductModel(
      {required this.id,
      required this.stock,
      required this.price,
      required this.title,
      required this.createAt,
      this.isFeatured,
      this.brand,
      required this.shop,
      this.description,
      this.details,
      this.categories,
      this.images,
      required this.productType,
      this.productAttributes,
      this.productVariations});

  static ProductModel empty() => ProductModel(
      id: '',
      stock: 0,
      price: 0.0,
      title: '',
      productType: '',
      createAt: DateTime.now(),
      shop: ShopModel.empty());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'stock': stock,
      'price': price,
      'createAt': createAt.toIso8601String(),
      'isFeatured': isFeatured,
      'brand': brand?.toJson(),
      'shop': shop.toJson(), // Giả sử ShopModel có phương thức toJson()
      'description': description,
      'details': details ?? {},
      'categories': categories != null
          ? categories!.map((e) => e.toJson()).toList()
          : [],
      'images': images ?? [],
      'productType': productType,
      'productAttributes': productAttributes != null
          ? productAttributes!.map((e) => e.toJson()).toList()
          : [],
      'productVariations': productVariations != null
          ? productVariations!.map((e) => e.toJson()).toList()
          : [],
    };
  }

  // Hàm helper bất đồng bộ dùng trong fromSnapshotAsync
  static Future<ProductModel> _fromMapAsync(
      Map<String, dynamic> data, String id) async {
    double parsedPrice;
    if (data['price'] == null) {
      parsedPrice = 0.0;
    } else if (data['price'] is num) {
      parsedPrice = (data['price'] as num).toDouble();
    } else if (data['price'] is String) {
      String cleanedPrice =
      data['price'].replaceAll(RegExp(r'[^\d,\.]'), '');
      if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(cleanedPrice)) {
        cleanedPrice = cleanedPrice.replaceAll('.', '');
      } else {
        if (cleanedPrice.contains(',') && !cleanedPrice.contains('.')) {
          cleanedPrice = cleanedPrice.replaceAll(',', '.');
        } else {
          cleanedPrice = cleanedPrice.replaceAll(',', '');
        }
      }
      parsedPrice = double.tryParse(cleanedPrice) ?? 0.0;
    } else {
      parsedPrice = 0.0;
    }

    DateTime parsedCreatedAt;
    final createdAtData = data['createdAt'];
    if (createdAtData == null) {
      parsedCreatedAt = DateTime.now();
    } else if (createdAtData is Map<String, dynamic>) {
      final int seconds = createdAtData['_seconds'] ?? 0;
      final int nanoseconds = createdAtData['_nanoseconds'] ?? 0;
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + (nanoseconds / 1000000).round(),
      );
    } else if (createdAtData is Timestamp) {
      parsedCreatedAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      parsedCreatedAt = DateTime.tryParse(createdAtData) ?? DateTime.now();
    } else {
      // Nếu không khớp với các kiểu đã biết, log thêm thông tin và gán default
      print("Invalid created_at format: $createdAtData, type: ${createdAtData.runtimeType}");
      parsedCreatedAt = DateTime.now();
    }



    // Lấy Brand, Shop và Categories thông qua repository (async)
    final brandRepository = BrandRepository.instance;
    final categoryRepository = CategoryRepository.instance;
    final shopRepository = ShopRepository.instance;

    BrandModel? brand = data['brandId'] != null
        ? await brandRepository.getBrandById(data['brandId'])
        : null;
    ShopModel shop = ShopModel.empty();
    if (data['shopId'] != null) {
      shop = await shopRepository.getShopById(data['shopId']);
    }
    List<CategoryModel> categories = data['categoryIds'] != null
        ? await categoryRepository
        .getCategoriesByIds(List<String>.from(data['categoryIds']))
        : [];

    // Xử lý details: ép kiểu an toàn tránh null
    Map<String, String> details = {};
    if (data['details'] != null && data['details'] is Map) {
      details = Map<String, String>.fromEntries(
        (data['details'] as Map)
            .entries
            .where((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty)
            .map((entry) => MapEntry(entry.key.toString(), entry.value.toString())),
      );
    }

    return ProductModel(
      id: id,
      title: data['title'] ?? " ",
      stock: data['stock'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      price: parsedPrice,
      createAt: parsedCreatedAt,
      description: data['description'] ?? "",
      details: details,
      productType: data['productType'] ?? "",
      images: data['images'] != null
          ? List<String>.from(data['images'])
          : data['Images'] != null
          ? List<String>.from(data['Images'])
          : [],
      productAttributes: data['productAttributes'] != null
          ? List<ProductAttributeModel>.from((data['productAttributes'] as List)
          .map((e) => ProductAttributeModel.fromJson(e)))
          : [],
      productVariations: data['ProductVariations'] != null
          ? List<ProductVariationModel>.from((data['ProductVariations'] as List)
          .map((e) => ProductVariationModel.fromJson(e)))
          : [],
      // Với dữ liệu từ Firestore, ta phải lấy brand, shop theo id riêng
      brand: brand,
      shop: shop,
      categories: categories,
    );
  }

  // Factory constructor từ JSON (synchronous)
  static Future<ProductModel> toModelFromJson(Map<String, dynamic> json) async {
    return await ProductModel._fromMapAsync(json, json['id']);
  }
  // Factory constructor bất đồng bộ dùng cho Firestore snapshot
  static Future<ProductModel> fromSnapshotAsync(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
    final data = documentSnapshot.data()!;
    return await ProductModel._fromMapAsync(data, documentSnapshot.id);
  }
}
