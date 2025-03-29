import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_app/features/shop/models/product_model.dart';
import 'package:my_app/utils/constants/api_constants.dart';
import '../../../utils/local_storage/storage_utility.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  //get limited featured products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await _db
          .collection("Products").limit(100)
          .get();
      final products = await Future.wait(
          snapshot.docs.map((doc) => ProductModel.fromSnapshotAsync(doc))
      );
      // Lọc các product có images khác null và không rỗng
      final filteredProducts = products
          .where((product) => product.images != null && product.images!.isNotEmpty)
          .toList();
      return filteredProducts;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      if (kDebugMode) {
        print("Loi : getFeaturedProducts() in REPO: ${e.toString()}");
      }
      throw "message: $e";
    }
  }

  // Gọi API từ Node.js
  Future<Map<String, dynamic>> fetchProductsFromApi(String categoryId,
      {int limit = 20, String? startAfter}) async {
    final url = Uri.parse(
        '$baseUrl/products-by-category/$categoryId?limit=$limit${startAfter != null ? '&startAfter=$startAfter' : ''}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products from API');
    }
  }

  Future<Map<String, dynamic>> getProductsByCategory1(
      {required String categoryId, int limit = 20, String? startAfter}) async {
    try {
      Query query = _db
          .collection('Products')
          .where('category_ids', arrayContains: categoryId)
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (startAfter != null) {
        DateTime startAfterDate = DateTime.parse(startAfter);
        query = query.startAfter([Timestamp.fromDate(startAfterDate)]);
      }

      QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      String? nextPageToken;
      if (snapshot.docs.isNotEmpty) {
        Timestamp lastCreatedAt = snapshot.docs.last.get('created_at');
        nextPageToken = lastCreatedAt.toDate().toIso8601String();
      }

      return {'products': products, 'nextPageToken': nextPageToken};
    } catch (error) {
      print('Error fetching products by category: $error');
      throw Exception('Failed to load products');
    }
  }

  Future<Map<String, dynamic>> fetchProductsFromFirestore({
    String? categoryId,
    String? brandId,
    String? shopId,
    int limit = 50,
    String? startAfter,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Query query;

    // Xác định điều kiện truy vấn theo bộ lọc
    if (categoryId != null) {
      query = firestore
          .collection('Products')
          .where('category_ids', arrayContains: categoryId)
          .orderBy('created_at', descending: true)
          .limit(limit);
    } else if (brandId != null) {
      query = firestore
          .collection('Products')
          .where('brand_id', isEqualTo: brandId)
          .orderBy('created_at', descending: true)
          .limit(limit);
    } else if (shopId != null) {
      query = firestore
          .collection('Products')
          .where('shop_id', isEqualTo: shopId)
          .orderBy('created_at', descending: true)
          .limit(limit);
    } else {
      throw Exception('Phải truyền ít nhất một bộ lọc: categoryId, brandId hoặc shopId');
    }

    // Hỗ trợ phân trang nếu có startAfter (giả sử là ISO string của created_at)
    if (startAfter != null) {
      DateTime? startAfterDate = DateTime.tryParse(startAfter);
      if (startAfterDate != null) {
        query = query.startAfter([Timestamp.fromDate(startAfterDate)]);
      }
    }

    QuerySnapshot snapshot = await query.get();

    // Map dữ liệu sản phẩm, thêm id của document
    List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {'id': doc.id, ...data};
    }).toList();

    // Tạo nextPageToken dựa trên trường 'created_at' của document cuối
    String? nextPageToken;
    if (snapshot.docs.isNotEmpty) {
      Timestamp lastTimestamp = snapshot.docs.last.get('created_at');
      nextPageToken = lastTimestamp.toDate().toIso8601String();
    }

    return {'products': products, 'nextPageToken': nextPageToken};
  }

  Future<Map<String, dynamic>> getProducts({
    String? categoryId,
    String? brandId,
    String? shopId,
    int limit = 20,
    String? startAfter,
  }) async {
    final localStorage = DLocalStorage.instance();

    // Xác định cacheKey dựa vào tham số truyền vào
    String type = categoryId != null
        ? 'category'
        : brandId != null
        ? 'brand'
        : 'shop';
    String id = categoryId ?? brandId ?? shopId ?? '';
    final cacheKey = 'products_cache_${type}_$id';
    final timestampKey = 'products_cache_timestamp_${type}_$id';

    // Chỉ cache trang đầu tiên
    if (startAfter == null) {
      final cachedDataStr = localStorage.readData<String>(cacheKey);
      final cachedTimeStr = localStorage.readData<String>(timestampKey);
      if (cachedDataStr != null && cachedTimeStr != null) {
        final cachedTime = DateTime.tryParse(cachedTimeStr);
        if (cachedTime != null &&
            DateTime.now().difference(cachedTime) < Duration(hours: 24)) {
          return jsonDecode(cachedDataStr);
        }
      }
    }

    // Xây dựng URL API động dựa trên tham số truyền vào
    final url = Uri.parse(
        '$baseUrl/products-by-$type/$id?limit=$limit${startAfter != null ? '&startAfter=$startAfter' : ''}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final apiResult = jsonDecode(response.body);

        // Nếu đây là trang đầu tiên, lưu cache
        if (startAfter == null) {
          await localStorage.writeData(cacheKey, jsonEncode(apiResult));
          await localStorage.writeData(
              timestampKey, DateTime.now().toIso8601String());
        }
        return apiResult;
      } else {
        throw Exception('Failed to load products from API');
      }

      // Gọi Firestore thay vì gọi API Node.js
      // final firestoreResult = await fetchProductsFromFirestore(
      //   categoryId: categoryId,
      //   brandId: brandId,
      //   shopId: shopId,
      //   limit: limit,
      //   startAfter: startAfter,
      // );
      // // Nếu đây là trang đầu tiên, cập nhật cache
      // if (startAfter == null) {
      //   await localStorage.writeData(cacheKey, jsonEncode(firestoreResult));
      //   await localStorage.writeData(
      //       timestampKey, DateTime.now().toIso8601String());
      // }
      // return firestoreResult;
    } catch (e) {
      // Nếu API lỗi, sử dụng cache nếu có
      final cachedDataStr = localStorage.readData<String>(cacheKey);
      if (cachedDataStr != null) {
        return jsonDecode(cachedDataStr);
      } else {
        rethrow;
      }
    }
  }


  // Hàm tổng hợp: nếu API hoạt động, cập nhật cache, nếu không, trả về cache (nếu hợp lệ)
  Future<Map<String, dynamic>> getProductsByCategory(String categoryId,
      {int limit = 20, String? startAfter}) async {
    final localStorage = DLocalStorage.instance();
    final cacheKey = 'products_cache_$categoryId';
    final timestampKey = 'products_cache_timestamp_$categoryId';
    // Chỉ dùng cache cho trang đầu tiên (startAfter == null)
    if (startAfter == null) {
      final cachedDataStr = localStorage.readData<String>(cacheKey);
      final cachedTimeStr = localStorage.readData<String>(timestampKey);
      if (cachedDataStr != null && cachedTimeStr != null) {
        final cachedTime = DateTime.tryParse(cachedTimeStr);
        if (cachedTime != null &&
            DateTime.now().difference(cachedTime) < Duration(hours: 24)) {
          return jsonDecode(cachedDataStr);
        }
      }
    }
    // Nếu không có cache hợp lệ hoặc load thêm trang, gọi API
    try {
      final apiResult = await fetchProductsFromApi(categoryId,
          limit: limit, startAfter: startAfter);
      // Nếu đây là trang đầu tiên, cập nhật cache
      if (startAfter == null) {
        await localStorage.writeData(cacheKey, jsonEncode(apiResult));
        await localStorage.writeData(
            timestampKey, DateTime.now().toIso8601String());
      }
      return apiResult;
      // final firestoreResult = await getProductsByCategory1(
      //     limit: limit, startAfter: startAfter, categoryId:categoryId);
      //
      // // Nếu đây là trang đầu tiên, cập nhật cache
      // if (startAfter == null) {
      //   await localStorage.writeData(cacheKey, jsonEncode(firestoreResult));
      //   await localStorage.writeData(
      //       timestampKey, DateTime.now().toIso8601String());
      // }
      //
      // return firestoreResult;
    } catch (e) {
      // Nếu gọi API lỗi, nếu có cache thì sử dụng cache, còn không thì throw
      final cachedDataStr = localStorage.readData<String>(cacheKey);
      if (cachedDataStr != null) {
        return jsonDecode(cachedDataStr);
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> getFeaturedProductsPage({dynamic lastDoc}) async {
    print("=== getFeaturedProductsPage() START ===");

    // Nếu trang đầu tiên, thử lấy cache
    if (lastDoc == null) {
      print(">> Trang đầu tiên, kiểm tra cache...");
      final cachedData = DLocalStorage.instance().readData<String>('featured_products_cache');
      final cachedTimeStr = DLocalStorage.instance().readData<String>('featured_products_cache_timestamp');
      print(">> cachedData: $cachedData");
      print(">> cachedTimeStr: $cachedTimeStr");

      if (cachedData != null && cachedTimeStr != null) {
        final cachedTime = DateTime.tryParse(cachedTimeStr);
        print(">> cachedTime parsed: $cachedTime");
        if (cachedTime != null && DateTime.now().difference(cachedTime) < Duration(hours: 24)) {
          print(">> Cache hợp lệ, thời gian cache: ${DateTime.now().difference(cachedTime)}");
          final cacheMap = jsonDecode(cachedData);
          final jsonList = cacheMap['products'] as List<dynamic>;
          final lastDocInfo = cacheMap['lastDoc'];
          print(">> jsonList (cache): $jsonList");
          print("=== getFeaturedProductsPage() END - Trả về dữ liệu cache ===");
          return {'products': jsonList, 'lastDoc': lastDocInfo};
        } else {
          print(">> Cache đã hết hạn hoặc không hợp lệ");
        }
      } else {
        print(">> Không có dữ liệu cache");
      }
    }

    // Nếu không lấy được cache, query từ Firestore
    print(">> Query dữ liệu từ Firestore...");
    Query query = _db.collection("Products")
        .orderBy("created_at", descending: true)
        .limit(pageSize);

    if (lastDoc != null) {
      print(">> lastDoc không null, xử lý lastDoc");
      if (lastDoc is DocumentSnapshot) {
        print(">> lastDoc là DocumentSnapshot, dùng startAfterDocument(lastDoc)");
        query = query.startAfterDocument(lastDoc);
      } else if (lastDoc is Map<String, dynamic> && lastDoc['id'] != null) {
        print(">> lastDoc là Map, lấy DocumentSnapshot từ id");
        DocumentSnapshot lastDocSnapshot = await _db.collection("Products").doc(lastDoc['id']).get();
        query = query.startAfterDocument(lastDocSnapshot);
      }
    }

    QuerySnapshot snapshot = await query.get();
    print(">> Firestore snapshot docs count: ${snapshot.docs.length}");

    final products = await Future.wait(
        snapshot.docs.map((doc) {
          print(">> Đang parse doc id: ${doc.id}");
          return ProductModel.fromSnapshotAsync(doc as DocumentSnapshot<Map<String, dynamic>>);
        })
    );
    print(">> Tổng sản phẩm parse được: ${products.length}");

    // Lọc sản phẩm có trường images hợp lệ
    final filteredProducts = products.where((p) {
      bool valid = p.images != null && p.images!.isNotEmpty;
      if (!valid) {
        print(">> Sản phẩm '${p.title}' bị loại do images trống");
      }
      return valid;
    }).toList();

    print(">> filteredProducts count: ${filteredProducts.length}");
    filteredProducts.forEach((product) => print(">> Sản phẩm sau filter: ${product.title}"));

    DocumentSnapshot? newLastDoc;
    if (snapshot.docs.isNotEmpty) {
      newLastDoc = snapshot.docs.last;
      print(">> newLastDoc id: ${newLastDoc.id}");
    } else {
      print(">> Không có docs trong snapshot");
    }

    // Nếu đây là trang đầu tiên, lưu cache (và lưu thêm metadata của lastDoc để phục vụ load more)
    if (lastDoc == null && filteredProducts.isNotEmpty && newLastDoc != null) {
      print(">> Lưu cache cho trang đầu tiên");
      final lastDocInfo = {
        'id': newLastDoc.id,
        'created_at': (newLastDoc.data() as Map<String, dynamic>)['created_at'] != null
            ? ((newLastDoc.data() as Map<String, dynamic>)['created_at'] as Timestamp)
            .toDate()
            .toIso8601String()
            : null,
      };
      final Map<String, dynamic> cacheData = {
        'products': filteredProducts.map((p) {
          final json = p.toJson();
          print(">> Lưu cache - sản phẩm: ${json['Images']}");
          return json;
        }).toList(),
        'lastDoc': lastDocInfo,
      };
      await DLocalStorage.instance().writeData('featured_products_cache', jsonEncode(cacheData));
      await DLocalStorage.instance().writeData('featured_products_cache_timestamp', DateTime.now().toIso8601String());
      print(">> Cache đã được lưu");
    }

    print("=== getFeaturedProductsPage() END - Trả về Firestore data ===");
    return {'products': filteredProducts, 'lastDoc': newLastDoc};
  }



  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _db.collection("Products").limit(500).get();
      final products = await Future.wait(
          snapshot.docs.map((doc) => ProductModel.fromSnapshotAsync(doc))
      );
      // Lọc các product có images khác null và không rỗng
      final filteredProducts = products
          .where((product) => product.images != null && product.images!.isNotEmpty)
          .toList();
      return filteredProducts;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      if (kDebugMode) {
        print("Loi : getAllProducts() in REPO: ${e.toString()}");
      }
      throw "message: $e";
    }
  }

  Future<List<ProductModel>> getProductsByIds(List<String> productIds) async {
    try {
      // Lấy tất cả sản phẩm từ Firestore
      final snapshot = await _db.collection("Products").get();
      // Map productId -> ProductModel
      // Chuyển đổi dữ liệu Firestore thành danh sách Future<ProductModel>
      final allProductsFuture = snapshot.docs
          .where((doc) => productIds.contains(doc.id)) // Lọc sản phẩm theo ID
          .map((doc) => ProductModel.fromSnapshotAsync(doc)) // Gọi hàm async
          .toList();

      final allProducts = await Future.wait(allProductsFuture);
      // Lọc các product có images khác null và không rỗng
      final filteredProducts = allProducts
          .where((product) => product.images != null && product.images!.isNotEmpty)
          .toList();
      // Sắp xếp danh sách theo thứ tự của productIds
      filteredProducts.sort((a, b) {
        final indexA = productIds.indexOf(a.id);
        final indexB = productIds.indexOf(b.id);
        return indexA.compareTo(indexB);
      });
      return filteredProducts;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw "message: $e";
    }
  }


  Future<List<ProductModel>> getProductsBySearchQuery(String query) async {
    try {
      // Lấy tất cả các sản phẩm từ Firestore
      final snapshot = await _db.collection("Products").get();
      // Chuyển query về chữ thường
      String lowerCaseQuery = query.toLowerCase();
      final allProductsFuture =  snapshot.docs.map((doc)=>ProductModel.fromSnapshotAsync(doc)).toList();
      final allProducts = await Future.wait(allProductsFuture);
      // Lọc các sản phẩm có title chứa query
      final titleFilteredProducts = allProducts
          .where((product) => product.title.toLowerCase().contains(lowerCaseQuery))
          .toList();
      // Lọc các product có images khác null và không rỗng
      final filteredProducts = titleFilteredProducts
          .where((product) => product.images != null && product.images!.isNotEmpty)
          .toList();
      return filteredProducts;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw "message: $e";
    }
  }

  Future<void> deleteDocumentsExceptRange(String collectionName, String startId, String endId) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection(collectionName);

    // Truy xuất tất cả các document trong collection
    QuerySnapshot snapshot = await collectionRef.get();

    // Lặp qua từng document và kiểm tra xem ID của nó có nằm trong phạm vi cần giữ lại hay không
    for (DocumentSnapshot doc in snapshot.docs) {
      String docId = doc.id;

      // Kiểm tra xem ID của document có nằm trong phạm vi từ startId đến endId hay không
      if (docId.compareTo(startId) >= 0 || docId.compareTo(endId) <= 0) {
        // Nếu không nằm trong phạm vi, xóa document này
        await collectionRef.doc(docId).delete().catchError((error) {
          print("Failed to delete document: $error");
        });
      }
    }
  }

  Future<void> updateDocumentsInRange(String collectionName, String startId, String endId) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection(collectionName);

    // Truy vấn tất cả các document trong collection
    QuerySnapshot snapshot = await collectionRef.get();

    // Lặp qua từng document và kiểm tra xem ID của nó có nằm trong phạm vi cần cập nhật hay không
    for (DocumentSnapshot doc in snapshot.docs) {
      String docId = doc.id;

      // Kiểm tra xem ID của document có nằm trong phạm vi từ startId đến endId hay không
      if (docId.compareTo(startId) >= 0 && docId.compareTo(endId) <= 0) {
        var productData = doc.data() as Map<String, dynamic>;
        var brand = productData['Brand'] as Map<String, dynamic>;
        var images = productData['Images'];

        // Kiểm tra nếu product có trường Images và Images không phải là danh sách rỗng
        if (images != null && images is List && images.isNotEmpty) {
          // Cập nhật trường Brand.Image
          await doc.reference.update({
            'Brand.Image': images[0],
          });
          print('Updated Product ${docId} with new Brand Image');
        }
      }
    }
  }

  Future<List<ProductModel>> fetchProductsByQuery(Query query) async {
    try {
      final querySnapshot = await query.get();
      final productFutures = querySnapshot.docs.map((doc)=>ProductModel.fromSnapshotAsync(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
      final productList = await Future.wait(productFutures);
      // Lọc để chỉ trả về những product có images không null và không rỗng
    final filteredProducts = productList
        .where((product) => product.images != null && product.images!.isNotEmpty)
        .toList();

    return filteredProducts;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      print('Loi: fetchProductsByQuery: ${e.toString()}  ');
      throw "message: fetchProductsByQuery  $e";
    }
  }

  Future<List<ProductModel>> getFavouriteProducts(List<String> productIds) async {
    try {
      final snapshot = await _db.collection("Products").where(FieldPath.documentId,whereIn: productIds).get();
      return await Future.wait( snapshot.docs.map((e) => ProductModel.fromSnapshotAsync(e)).toList());
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw "message: $e";
    }
  }

  Future<List<ProductModel>> getProductsForBrand(
      {required String brandId, int limit = -1}) async {
    try {
      final querySnapshot = limit == -1
          ? await _db
              .collection('Products')
              .where('Brand.Id', isEqualTo: brandId)
              .get()
          : await _db
              .collection('Products')
              .where('Brand.Id', isEqualTo: brandId)
              .limit(limit)
              .get();
      final productFutures = querySnapshot.docs.map((doc)=>ProductModel.fromSnapshotAsync(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
      final productList = await Future.wait(productFutures);
      // Lọc để chỉ trả về những product có images không null và không rỗng
    final filteredProducts = productList
        .where((product) => product.images != null && product.images!.isNotEmpty)
        .toList();

    return filteredProducts;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw "message: $e";
    }
  }

  Future<List<ProductModel>> getProductsForCategory(
      {required String categoryId, int limit = 400}) async {
    try {
      QuerySnapshot productCategoryQuery = limit == -1
          ? await _db
              .collection('ProductCategory')
              .where('categoryId', isEqualTo: categoryId)
              .get()
          : await _db
              .collection('ProductCategory')
              .where('categoryId', isEqualTo: categoryId)
              .limit(limit)
              .get();
      List<String> productIds = productCategoryQuery.docs
          .map((doc) => doc['productId'] as String)
          .toList();
      final productsQuery = await _db
          .collection('Products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();
      final productFutures = productsQuery.docs.map((doc)=>ProductModel.fromSnapshotAsync(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
      final productList = await Future.wait(productFutures);
      // Lọc để chỉ trả về những product có images không null và không rỗng
    final filteredProducts = productList
        .where((product) => product.images != null && product.images!.isNotEmpty)
        .toList();

    return filteredProducts;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw "message: $e";
    }
  }
  Future<List<ProductModel>> getProductsForCategory1({required String categoryId}) async {
    // Lấy tất cả các sản phẩm từ Firestore
    final snapshot = await _db.collection('Products').where('CategoryId', isEqualTo: categoryId).get();
    // Lọc cục bộ các sản phẩm theo CategoryId đã chuyển thành chuỗi
    final productFutures = snapshot.docs
        .map((doc) => ProductModel.fromSnapshotAsync(doc))
        .toList();
    // Chờ tất cả Future hoàn thành
    final products = await Future.wait(productFutures);
    // Lọc để chỉ trả về những product có images không null và không rỗng
    final filteredProducts = products
        .where((product) => product.images != null && product.images!.isNotEmpty)
        .toList();

    return filteredProducts;
  }

}


