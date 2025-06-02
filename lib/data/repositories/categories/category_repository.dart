import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:app_my_app/features/shop/models/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:app_my_app/utils/constants/api_constants.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';

class CategoryRepository extends GetxController {
  static CategoryRepository get instance => Get.find();
  //variables
  final _db = FirebaseFirestore.instance;
//get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _db.collection('Categories').get();
      final list = snapshot.docs
          .map((document) => CategoryModel.fromSnapshot(document))
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

  Future<List<CategoryModel>> fetchTopCategories({int limit = 20}) async {
    try {
      // 1. Lấy toàn bộ Products
      QuerySnapshot productSnapshot = await _db.collection('Products').get();
      // 2. Đếm số lượng sản phẩm cho mỗi category và lưu hình ảnh đại diện (nếu có)
      final Map<String, int> categoryCount = {};
      final Map<String, String> categoryImages = {};

      for (var doc in productSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['categoryIds'] != null && data['categoryIds'] is List) {
          List<dynamic> catIds = data['categoryIds'];
          for (var catId in catIds) {
            if (catId != null) {
              categoryCount[catId] = (categoryCount[catId] ?? 0) + 1;
              // Nếu chưa có hình đại diện cho category và có trường images
              if (!categoryImages.containsKey(catId) &&
                  data['images'] != null &&
                  data['images'] is List &&
                  (data['images'] as List).isNotEmpty) {
                categoryImages[catId] = (data['images'] as List)[0];
              }
            }
          }
        }
      }

      // 3. Sắp xếp các category theo số lượng sản phẩm giảm dần và lấy top limit
      List<String> sortedCategoryIds = categoryCount.keys.toList();
      sortedCategoryIds.sort((a, b) => categoryCount[b]!.compareTo(categoryCount[a]!));
      sortedCategoryIds = sortedCategoryIds.take(limit).toList();

      // 4. Truy vấn bảng Categories theo batch (mỗi batch tối đa 10 phần tử)
      List<CategoryModel> categories = [];
      const int batchSize = 10;
      for (int i = 0; i < sortedCategoryIds.length; i += batchSize) {
        final int endIndex = (i + batchSize > sortedCategoryIds.length) ? sortedCategoryIds.length : i + batchSize;
        final List<String> batchIds = sortedCategoryIds.sublist(i, endIndex);

        QuerySnapshot categorySnapshot = await _db
            .collection('Categories')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        for (var doc in categorySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String catId = doc.id;
          final String? image = categoryImages[catId];
          final int? count = categoryCount[catId];
          final categoryModel = CategoryModel.fromMap(catId, data, image,count);
          categories.add(categoryModel);
        }
      }

      // 5. Sắp xếp lại danh sách theo số lượng sản phẩm giảm dần (nếu cần)
      categories.sort((a, b) => b.productCount!.compareTo(a.productCount!));
      return categories;
    } catch (error) {
      print("Error retrieving top categories: $error");
      throw Exception(error);
    }
  }

//get sub categories
  Future<List<CategoryModel>> getSubCategories(String categoryId) async{
    try{
      final snapshot = await _db.collection("Categories").where("ParentId",isEqualTo: categoryId).get();
      final result = snapshot.docs.map((e) => CategoryModel.fromSnapshot(e)).toList();
      return result;
    }on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
//upload to cloud
  Future<void> uploadDummyData(List<CategoryModel> categories) async {
    try {
      final storage = Get.put(TFirebaseStorageService());
      for (var category in categories) {
        final file = await storage.getImageDataFromAssets(category.image);
        final url =
            await storage.uploadImageData('Categories', file, category.name);
        category.image = url;
        await _db
            .collection('Categories')
            .doc(category.id)
            .set(category.toJson());
      }
    }  catch (e) {
      throw "message: $e" ;
    }
  }

  Future<List<CategoryModel>> getCategoriesByIds(List<String> categoryIds) async {
    List<CategoryModel> categories = [];
    try {
      final snapshot = await _db.collection("Categories").where(FieldPath.documentId, whereIn: categoryIds).get();
      final result = snapshot.docs.map((e) => CategoryModel.fromSnapshot(e)).toList();
      return result;
    } catch (e) {
      print('Error fetching categories: $e');
    }
    return categories;
  }

  Future<List<CategoryModel>> fetchTopCategories1() async {
    try {
      // 1. Lấy toàn bộ products
      final QuerySnapshot productSnapshot =
      await _db.collection('Products').get();
      print('Retrieved ${productSnapshot.docs.length} products');

      // 2. Đếm số lượng sản phẩm cho mỗi category và lưu lại image mẫu
      final Map<String, int> categoryCount = {};
      final Map<String, String> categoryImages = {};
      for (var doc in productSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['categoryIds'] != null &&
            data['categoryIds'] is List<dynamic>) {
          List<dynamic> catIds = data['categoryIds'];
          for (var catId in catIds) {
            if (catId != null) {
              categoryCount[catId] = (categoryCount[catId] ?? 0) + 1;
              if (categoryImages[catId] == null &&
                  data['images'] != null &&
                  data['images'] is List<dynamic> &&
                  (data['images'] as List).isNotEmpty) {
                categoryImages[catId] = data['images'][0];
              }
            }
          }
        }
      }

      // 3. Sắp xếp các category_id theo số lượng giảm dần và lấy top 20
      List<String> sortedCategoryIds = categoryCount.keys.toList()
        ..sort((a, b) => categoryCount[b]!.compareTo(categoryCount[a]!));
      sortedCategoryIds = sortedCategoryIds.take(20).toList();

      // 4. Truy vấn bảng Categories theo sortedCategoryIds với batch (Firestore giới hạn whereIn tối đa 10 phần tử)
      List<Map<String, dynamic>> categories = [];
      const int batchSize = 10;
      for (int i = 0; i < sortedCategoryIds.length; i += batchSize) {
        final end = (i + batchSize > sortedCategoryIds.length)
            ? sortedCategoryIds.length
            : i + batchSize;
        final List<String> batchIds = sortedCategoryIds.sublist(i, end);
        final QuerySnapshot categorySnapshot = await _db
            .collection('Categories')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        for (var doc in categorySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['productCount'] = categoryCount[doc.id];
          data['categoryImage'] = categoryImages[doc.id];
          categories.add(data);
        }
      }

      // 5. Sắp xếp lại các category theo số lượng sản phẩm giảm dần
      categories.sort((a, b) =>
          (b['productCount'] as int).compareTo(a['productCount'] as int));

      final List<CategoryModel> categoriesModel = categories
          .map((jsonItem) => CategoryModel.fromJson(jsonItem))
          .toList();
      print("Successfully fetched top categories.");
      return categoriesModel;
    } catch (error) {
      print("Error retrieving top categories: $error");
      rethrow;
    }
  }

}
