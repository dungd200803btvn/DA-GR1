import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_store/data/repositories/brands/brand_repository.dart';
import 'package:t_store/data/repositories/categories/category_repository.dart';
import 'package:t_store/data/repositories/shop/shop_repository.dart';
import 'package:t_store/features/shop/models/brand_model.dart';
import 'package:t_store/features/shop/models/category_model.dart';
import 'package:t_store/features/shop/models/product_attribute_model.dart';
import 'package:t_store/features/shop/models/product_variation_model.dart';
import 'package:t_store/features/shop/models/shop_model.dart';

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
      'Title': title,
      'Stock': stock,
      'Price': price,
      'createAt': createAt.toIso8601String(),
      'IsFeatured': isFeatured,
      'Brand': brand?.toJson(),
      'Shop': shop.toJson(), // Giả sử ShopModel có phương thức toJson()
      'Description': description,
      'details': details ?? {},
      'categories': categories != null
          ? categories!.map((e) => e.toJson()).toList()
          : [],
      'images': images ?? [],
      'ProductType': productType,
      'ProductAttributes': productAttributes != null
          ? productAttributes!.map((e) => e.toJson()).toList()
          : [],
      'ProductVariations': productVariations != null
          ? productVariations!.map((e) => e.toJson()).toList()
          : [],
    };
  }

  // Hàm helper bất đồng bộ dùng trong fromSnapshotAsync
  static Future<ProductModel> _fromMapAsync(
      Map<String, dynamic> data, String id) async {
    // final fieldsToCheck = [
    //   'Title',
    //   'Price',
    //   'created_at',
    //   'Description',
    //   'ProductType',
    //   'images',
    //   'details',
    //   'brand_id',
    //   'shop_id',
    //   'category_ids'
    // ];
    //
    // for (final field in fieldsToCheck) {
    //   if (data[field] == null) {
    //     print('Field "$field" is null.');
    //   }
    // }
    //
    // if (data['details'] != null && data['details'] is Map) {
    //   (data['details'] as Map).forEach((key, value) {
    //     if (value == null) {
    //       print('details: key "$key" is null.');
    //     }
    //   });
    // }
    double parsedPrice;
    if (data['Price'] == null) {
      parsedPrice = 0.0;
    } else if (data['Price'] is num) {
      parsedPrice = (data['Price'] as num).toDouble();
    } else if (data['Price'] is String) {
      String cleanedPrice =
      data['Price'].replaceAll(RegExp(r'[^\d,\.]'), '');
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
    final createdAtData = data['created_at'];
    if (createdAtData == null) {
      // Nếu created_at null, gán giá trị mặc định hoặc xử lý theo yêu cầu
      print("Warning: created_at is null, assigning DateTime.now() as default.");
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

    BrandModel? brand = data['brand_id'] != null
        ? await brandRepository.getBrandById(data['brand_id'])
        : null;
    ShopModel shop = ShopModel.empty();
    if (data['shop_id'] != null) {
      shop = await shopRepository.getShopById(data['shop_id']);
    }
    List<CategoryModel> categories = data['category_ids'] != null
        ? await categoryRepository
        .getCategoriesByIds(List<String>.from(data['category_ids']))
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
      title: data['Title'] ?? " ",
      stock: data['Stock'] ?? 0,
      isFeatured: data['IsFeatured'] ?? false,
      price: parsedPrice,
      createAt: parsedCreatedAt,
      description: data['Description'] ?? "",
      details: details,
      productType: data['ProductType'] ?? "",
      images: data['images'] != null
          ? List<String>.from(data['images'])
          : data['Images'] != null
          ? List<String>.from(data['Images'])
          : [],
      productAttributes: data['ProductAttributes'] != null
          ? List<ProductAttributeModel>.from((data['ProductAttributes'] as List)
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
