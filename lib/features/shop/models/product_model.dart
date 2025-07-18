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
  DocumentSnapshot? snapshot;

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
      this.productVariations,
      this.snapshot});

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
  static Future<ProductModel> fromMapAsync(
      Map<String, dynamic> data,
      String id,
      DocumentSnapshot<Map<String, dynamic>>? doc) async {

    // Tính giá
    double parsedPrice = _parsePrice(data['price']);

    // Parse createdAt
    DateTime parsedCreatedAt = _parseCreatedAt(data['createdAt']);

    // Lấy instance repos
    final brandRepository = BrandRepository.instance;
    final categoryRepository = CategoryRepository.instance;
    final shopRepository = ShopRepository.instance;

    // Tạo các future nhưng chưa await
    final brandFuture = data['brandId'] != null
        ? brandRepository.getBrandById(data['brandId'])
        : Future.value(null);

    final shopFuture = data['shopId'] != null
        ? shopRepository.getShopById(data['shopId'])
        : Future.value(ShopModel.empty());

    final categoriesFuture = data['categoryIds'] != null
        ? categoryRepository.getCategoriesByIds(List<String>.from(data['categoryIds']))
        : Future.value(<CategoryModel>[]);

    // Run song song
    final results = await Future.wait([
      brandFuture,
      shopFuture,
      categoriesFuture,
    ]);

    // Giải kết quả
    final brand = results[0] as BrandModel?;
    final shop = results[1] as ShopModel;
    final categories = results[2] as List<CategoryModel>;

    // Xử lý details
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
      brand: brand,
      shop: shop,
      categories: categories,
      snapshot: doc,
    );
  }

  static double _parsePrice(dynamic priceData) {
    if (priceData == null) return 0.0;
    if (priceData is num) return priceData.toDouble();
    if (priceData is String) {
      String cleaned = priceData.replaceAll(RegExp(r'[^\d,\.]'), '');
      if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(cleaned)) {
        cleaned = cleaned.replaceAll('.', '');
      } else {
        cleaned = cleaned.contains(',') && !cleaned.contains('.')
            ? cleaned.replaceAll(',', '.')
            : cleaned.replaceAll(',', '');
      }
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseCreatedAt(dynamic createdAtData) {
    if (createdAtData == null) return DateTime.now();
    if (createdAtData is Map<String, dynamic>) {
      final int seconds = createdAtData['_seconds'] ?? 0;
      final int nanoseconds = createdAtData['_nanoseconds'] ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + (nanoseconds / 1000000).round(),
      );
    }
    if (createdAtData is Timestamp) return createdAtData.toDate();
    if (createdAtData is String) {
      return DateTime.tryParse(createdAtData) ?? DateTime.now();
    }
    return DateTime.now();
  }


  // Factory constructor bất đồng bộ dùng cho Firestore snapshot
  static Future<ProductModel> fromSnapshotAsync(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
    final data = documentSnapshot.data()!;
    return await ProductModel.fromMapAsync(data, documentSnapshot.id,documentSnapshot);
  }
}
