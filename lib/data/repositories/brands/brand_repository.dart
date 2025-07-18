import 'dart:convert';
import 'package:app_my_app/data/repositories/product/product_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:app_my_app/features/shop/models/brand_category_model.dart';
import 'package:app_my_app/features/shop/models/brand_model.dart';
import 'package:http/http.dart' as http;
import '../../../features/shop/models/shop_model.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../../utils/local_storage/storage_utility.dart';

class BrandRepository extends GetxController{
  static BrandRepository get instance => Get.find();
  //variables
final _db = FirebaseFirestore.instance;
final ProductRepository productRepository = ProductRepository.instance;
  List<BrandModel>? _cachedTopBrands;
//get all brands
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final snapshot = await _db.collection('Brands').get();
      final list = snapshot.docs
          .map((document) => BrandModel.fromSnapshot(document))
          .toList();
      return list;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Lấy top brands theo giới hạn truyền vào (mặc định 20)
  Future<List<BrandModel>> fetchTopBrands( {int limit = 20}) async {
    final startTime = DateTime.now();
    try {
      if (_cachedTopBrands != null&& limit ==20) return _cachedTopBrands!;
      // 1. Lấy toàn bộ products
      final productsDoc = await productRepository.getAllProductsDoc();
      // 2. Đếm số lượng sản phẩm cho mỗi brand
      Map<String, int> brandCount = {};
      for (var doc in productsDoc) {
        final data = doc.data() as Map<String, dynamic>;
        final String? brandId = data['brandId'];
        if (brandId != null) {
          brandCount[brandId] = (brandCount[brandId] ?? 0) + 1;
        }
      }

      // 3. Sắp xếp các brandId theo số lượng giảm dần và lấy top theo giới hạn
      List<String> sortedBrandIds = brandCount.keys.toList()
        ..sort((a, b) => brandCount[b]!.compareTo(brandCount[a]!));
      sortedBrandIds = sortedBrandIds.take(limit).toList();

      // 4. Truy vấn bảng Brands theo sortedBrandIds với batch (Firestore giới hạn whereIn tối đa 10 phần tử)
      List<Map<String, dynamic>> brands = [];
      const int batchSize = 10;
      for (int i = 0; i < sortedBrandIds.length; i += batchSize) {
        final int end =
        (i + batchSize < sortedBrandIds.length) ? i + batchSize : sortedBrandIds.length;
        final List<String> batchIds = sortedBrandIds.sublist(i, end);
        QuerySnapshot brandSnapshot = await _db
            .collection('Brands')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();
        for (var doc in brandSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['productCount'] = brandCount[doc.id];
          brands.add(data);
        }
      }
      // 5. Sắp xếp lại các brand theo số lượng sản phẩm giảm dần
      brands.sort((a, b) =>
          (b['productCount'] as int).compareTo(a['productCount'] as int));
      print("Successfully fetched top brands.");
      final List<BrandModel> brandsModel = brands
          .map((jsonItem) => BrandModel.fromJson(jsonItem))
          .toList();
      _cachedTopBrands = brandsModel;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("🔥 Thời gian load top brands : ${duration.inMilliseconds}ms");
      return brandsModel;
    } catch (error) {
      print("Error retrieving top brands: $error");
      rethrow;
    }
  }

  Future<List> fetchTopItems(int top, {required String fetchType}) async {
    // Xác định cache key và key của JSON trả về
    final storage = DLocalStorage.instance();
    final String cacheKey = 'top_${fetchType}_cache';
    final String cacheTimeKey = 'top_${fetchType}_cache_timestamp';
    const cacheDuration = Duration(hours: 24);
    final String jsonKey = fetchType == 'brands' ? 'topBrands' : 'topShops';

    // Kiểm tra cache
    final String? cachedData = storage.readData<String>(cacheKey);
    final String? cachedTimeString = storage.readData<String>(cacheTimeKey);
    if (cachedData != null && cachedTimeString != null) {
      final cachedTime = DateTime.tryParse(cachedTimeString);
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime) < cacheDuration) {
        final Map<String, dynamic> data = jsonDecode(cachedData);
        final List<dynamic> itemsJson = data[jsonKey];
        // Nếu cache đủ số lượng phần tử thì chỉ trả về phần tử cần thiết
        if (itemsJson.length >= top) {
          final List items = itemsJson
              .take(top)
              .map((jsonItem) => fetchType == 'brands'
              ? BrandModel.fromJson(jsonItem)
              : ShopModel.fromJson(jsonItem))
              .toList();
          return items;
        }
      }
    }

    // Nếu cache không tồn tại hoặc không đủ số lượng, gọi API
    final url = Uri.parse('$baseUrl/top-$fetchType?limit=$top');
    try {
      print("Url: $url");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Cập nhật cache
        await storage.writeData(cacheKey, response.body);
        await storage.writeData(cacheTimeKey, DateTime.now().toIso8601String());
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> itemsJson = data[jsonKey];
        final List items = itemsJson
            .map((jsonItem) => fetchType == 'brand'
            ? BrandModel.fromJson(jsonItem)
            : ShopModel.fromJson(jsonItem))
            .toList();
        return items;
      } else {
        print('API error: status code ${response.body}');
      }
    } catch (e) {
      print('Error calling API: $e');
      // Nếu API call thất bại, cố gắng trả về cache nếu có
      if (cachedData != null) {
        final Map<String, dynamic> data = jsonDecode(cachedData);
        final List<dynamic> itemsJson = data[jsonKey];
        final List items = itemsJson
            .map((jsonItem) => fetchType == 'brand'
            ? BrandModel.fromJson(jsonItem)
            : ShopModel.fromJson(jsonItem))
            .toList();
        return items;
      }
    }
    return [];
  }

  Future<List<BrandModel>> getUniqueBrandIdsByCategoryId(String categoryId) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('Products');
    // Truy vấn các sản phẩm có CategoryId bằng với categoryId truyền vào
    QuerySnapshot snapshot = await collectionRef.where('CategoryId', isEqualTo: categoryId).get();
    Set<String> brandIds = {};
    // Duyệt qua các tài liệu và thêm Brand.Id vào set
    for (DocumentSnapshot doc in snapshot.docs) {
      var productData = doc.data() as Map<String, dynamic>;
      var brand = productData['Brand'] as Map<String, dynamic>;
      if (brand != null && brand['id'] != null) {
        brandIds.add(brand['id'] as String);

      }
      print(brand['id']);
    }

    final brandsQuery = brandIds.isNotEmpty
        ? await _db.collection('Brands').where("id", whereIn: brandIds).get()
        : await _db.collection('Brands').get();
    List<BrandModel> brands = brandsQuery.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
    return brands;
  }

  Future<Set<String>> getUniqueBrandIds(String categoryId) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('Products');
    // Truy vấn các sản phẩm có CategoryId bằng với categoryId truyền vào
    QuerySnapshot snapshot = await collectionRef.where('CategoryId', isEqualTo: categoryId).get();
    Set<String> brandIds = {};
    // Duyệt qua các tài liệu và thêm Brand.Id vào set
    for (DocumentSnapshot doc in snapshot.docs) {
      var productData = doc.data() as Map<String, dynamic>;
      var brand = productData['Brand'] as Map<String, dynamic>;
      if (brand != null && brand['id'] != null) {
        brandIds.add(brand['id'] as String);

      }
      print(brand['id']);
    }
    return brandIds;
  }

  Future<void> genDataBrandCategory() async {
    final Map<int, Set<int>> brandCategories = {};
    List<BrandCategoryModel> data = [];
    QuerySnapshot snapshot = await _db.collection('Products').get();

    for (DocumentSnapshot doc in snapshot.docs) {
      var productData = doc.data() as Map<String, dynamic>;
      var brand = productData['Brand'] as Map<String, dynamic>;

      if (brand['id'] != null && productData['CategoryId'] != null) {
        int brandId = int.parse(brand['id'].toString());
        int categoryId = int.parse(productData['CategoryId'].toString());

        // Check if the brandId already exists in the map
        if (!brandCategories.containsKey(brandId)) {
          brandCategories[brandId] = {};
        }

        // Add the categoryId to the set of categories for this brandId
        brandCategories[brandId]!.add(categoryId);
      }
    }

    // Print the number of unique brandId-categoryId pairs
    int count = brandCategories.values.fold(0, (sum, set) => sum + set.length);
    print(count);

    // Print the brandId and their associated categoryIds
    brandCategories.forEach((brandId, categoryIds) {
      categoryIds.forEach((categoryId) {
        print("brandId: $brandId categoryId: $categoryId");
    BrandCategoryModel b =     BrandCategoryModel(brandId: brandId.toString(), categoryId: categoryId.toString());
        data.add(b);
      });
    });
      uploadBrandCategoryData(data);
  }

  Future<void> uploadBrandCategoryData(List<BrandCategoryModel> brandcategory) async {
    for (var v in brandcategory) {
      await _db
          .collection('BrandCategory')
          .add(v.toJson());
    }
  }
  Future<void> deleteAllDocumentsInCollection(String collectionPath) async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection(collectionPath);
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Create a batch to delete documents in bulk
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Commit the batch
    await batch.commit();
    print("All documents in $collectionPath have been deleted.");
  }

  Future<BrandModel?> getBrandById(String brandId) async{
    try{
      DocumentSnapshot<Map<String,dynamic>> snapshot =  await _db.collection('Brands').doc(brandId).get();
      if(snapshot.exists){
        return BrandModel.fromSnapshot(snapshot);
      }
    }catch(e){
        print('Loi: getBrandById: ${e.toString()} ');
    }
    return null;
  }




}