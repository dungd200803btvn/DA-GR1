import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../data/services/cloud_storage/firebase_storage_service.dart';

/// Helper functions for cloud-related operations.
class TCloudHelperFunctions {
  static Widget? checkSingleRecordState<T>(AsyncSnapshot<T> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data == null) {
      return const Center(child: Text('No Data Found!'));
    }

    if (snapshot.hasError) {
      return const Center(child: Text('Something went wrong.'));
    }

    return null;
  }

  static Widget? checkMultiRecordState<T>({required AsyncSnapshot<List<T>> snapshot, Widget? loader, Widget? error, Widget? nothingFound}) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      if (loader != null) return loader;
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
      if (nothingFound != null) return nothingFound;
      return const Center(child: Text(''));
    }

    if (snapshot.hasError) {
      if (error != null) return error;
      return const Center(child: Text('Something went wrong.'));
    }

    return null;
  }

  /// Create a reference with an initial file path and name and retrieve the download URL.
  static Future<String> getURLFromFilePathAndName(String path) async {
    try {
      if (path.isEmpty) return '';
      final ref = FirebaseStorage.instance.ref().child(path);
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw 'Something went wrong.';
    }
  }

  /// Retrieve the download URL from a given storage URI.
  static Future<String> getURLFromURI(String url) async {
    try {
      if (url.isEmpty) return '';
      final ref = FirebaseStorage.instance.refFromURL(url);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw 'Something went wrong.';
    }
  }
  static Future<String> uploadAssetImage(String assetUrl, String name)async {
    try {
      final storage = Get.put(TFirebaseStorageService());
      final file = await storage.getImageDataFromAssets(assetUrl);
      final url = await storage.uploadImageData('Notifications', file,assetUrl);
      return url;
    } catch (error) {
      print('Error uploadAssetImage: $error');
      return "";
    }
  }
}