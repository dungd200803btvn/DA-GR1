
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/utils/enum/enum.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  //get limited featured products
  Future<List<ProductModel>> getFeaturedProducts() async {
    final snapshot = await _db.collection("Products").get();
    return snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
    // } on FirebaseException catch (e) {
    //   throw e.message!;
    // } on PlatformException catch (e) {
    //   throw e.message!;
    // } catch (e) {
    //   throw "message: " + e.toString();
    // }
  }

  //upload to cloud
  //upload to cloud
  Future<void> uploadDummyData(List<ProductModel> products) async {
    final storage = Get.put(TFirebaseStorageService());
    for (var product in products) {
      final thumbnail =
      await storage.getImageDataFromAssets(product.thumbnail);
      final url = await storage.uploadImageData(
          'Products/Images', thumbnail, product.thumbnail.toString());
      product.thumbnail = url;
      //product list of images
      if (product.images != null && product.images!.isNotEmpty) {
        List<String> imagesUrl = [];
        for (var image in product.images!) {
          //get image data link from local assets
          final assetImage = await storage.getImageDataFromAssets(image);
          //upload image and get its url
          final url = await storage.uploadImageData(
              'Products/Images', assetImage, image);
          imagesUrl.add(url);
        }
        product.images!.clear();
        product.images!.addAll(imagesUrl);
      }
      //upload variation images
      if (product.productType == ProductType.variable.toString()) {
        for (var variation in product.productVariations!) {
          //get image data from local
          final assetImage =
          await storage.getImageDataFromAssets(variation.image);
          //upload image
          final url = await storage.uploadImageData(
              'Products/Images', assetImage, variation.image);
          variation.image = url;
        }
      }

      // Lưu dữ liệu cập nhật
      await _db.collection('Products').doc(product.id).set(product.toJson()); // Gọi phương thức toJson để chuyển đổi product thành JSON
    }
  }

}
