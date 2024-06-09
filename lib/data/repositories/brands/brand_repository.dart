import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:t_store/features/shop/models/brand_category_model.dart';
import 'package:t_store/features/shop/models/brand_model.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';

class BrandRepository extends GetxController{
  static BrandRepository get instance => Get.find();
  //variables
final _db = FirebaseFirestore.instance;
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

  //upload to cloud
  Future<void> uploadDummyData(List<BrandModel> brands) async {
    try {
      final storage = Get.put(TFirebaseStorageService());
      for (var brand in brands) {
        final file = await storage.getImageDataFromAssets(brand.image);
        final url =
        await storage.uploadImageData('Brands', file, brand.name);
        brand.image = url;
        await _db
            .collection('Brands')
            .doc(brand.id)
            .set(brand.toJson());
      }
    }  catch (e) {
      throw "message: "+e.toString() ;
    }
  }

  //get brands for category
  Future<List<BrandModel>> getBrandsForCategory(String categoryId) async{
    // try{
      QuerySnapshot brandCategoryQuery = await _db.collection('BrandCategory').where('categoryId',isEqualTo: categoryId).get();
      List<String> brandIds = brandCategoryQuery.docs.map((doc) => doc['brandId'] as String).toList();
      final brandsQuery = await _db.collection('Brands').where("Id",whereIn: brandIds).limit(10).get();
      List<BrandModel> brands = brandsQuery.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
      return brands;
    // }on FirebaseException catch (e) {
    //   throw TFirebaseException(e.code).message;
    // } on PlatformException catch (e) {
    //   throw TPlatformException(e.code).message;
    // } catch (e) {
    //   throw 'Something went wrong. Please try again';
    // }
  }

  Future<void> uploadBrandCategoryData(List<BrandCategoryModel> brandcategory) async {
    for (var v in brandcategory) {
      await _db
          .collection('BrandCategory')
          .add(v.toJson());
    }
  }



}