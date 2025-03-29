import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:t_store_app/data/repositories/product/product_repository.dart';
import 'package:t_store_app/features/shop/models/product_model.dart';
import 'package:t_store_app/utils/local_storage/storage_utility.dart';
import 'package:t_store_app/utils/popups/loader.dart';

import '../../../../l10n/app_localizations.dart';

class FavouritesController extends GetxController {
  static FavouritesController get instance => Get.find();
  late AppLocalizations lang;
  //variables
  final favourites = <String, bool>{}.obs;

  @override
  void onInit() {
    initFavourites();
    super.onInit();
  }
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }

  Future<void> initFavourites() async {
    final json = DLocalStorage.instance().readData('favourites');
    if (json != null) {
      final storedFavourites = jsonDecode(json) as Map<String, dynamic>;
      favourites.assignAll(
          storedFavourites.map((key, value) => MapEntry(key, value as bool)));
    }
  }

  bool isFavourite(String productId) {
    return favourites[productId] ?? false;
  }

  void toggleFavouriteProduct(String productId) {
    if (!favourites.containsKey(productId)) {
      favourites[productId] = true;
      saveFavouritesToStorage();
      TLoader.successSnackbar(title:lang.translate('add_wishlist'),message:lang.translate('add_wishlist') );
    } else {
      DLocalStorage.instance().removeData(productId);
      favourites.remove(productId);
      saveFavouritesToStorage();
      favourites.refresh();
      TLoader.successSnackbar(title: lang.translate('remove_wishlist'),message:lang.translate('remove_wishlist') );
    }
  }

  void saveFavouritesToStorage() {
    final encodedFavourites = json.encode(favourites);
    DLocalStorage.instance().writeData('favourites', encodedFavourites);
  }

  Future<List<ProductModel>> favouriteProducts() async{
    return await ProductRepository.instance.getFavouriteProducts(favourites.keys.toList());
  }
}
