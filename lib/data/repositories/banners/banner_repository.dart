import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:app_my_app/features/shop/models/banner_model.dart';
import 'package:app_my_app/utils/exceptions/format_exceptions.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';

class BannerRepository extends GetxController{
  static BannerRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  //get all banner actived
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final result = await _db.collection('Banners').get();
      return result.docs.map((e) => BannerModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    }
    on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  //upload to cloud
  Future<void> uploadDummyData(List<BannerModel> banners) async {
    try {
      final storage = Get.put(TFirebaseStorageService());
      for (var banner in banners) {
        final file = await storage.getImageDataFromAssets(banner.imageUrl);
        final url = await storage.uploadImageData('Banners', file, banner.targetScreen);
        banner.imageUrl = url;

        final documentReference = await _db.collection('Banners').add(banner.toJson());
        final id = documentReference.id;

        // Cập nhật ID tài liệu trong banner
        banner.id = id;

        // Lưu dữ liệu cập nhật
        await _db.collection('Banners').doc(id).update(banner.toJson());
      }
    } catch (error) {
      print('Error uploading dummy data: $error');
    }
  }

}