import 'dart:convert';
import 'package:get/get.dart';
import 'package:t_store/data/repositories/product/product_repository.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/utils/local_storage/storage_utility.dart';
import 'package:t_store/utils/popups/loader.dart';

class FavouritesController extends GetxController {
  static FavouritesController get instance => Get.find();

  //variables
  final favourites = <String, bool>{}.obs;

  @override
  void onInit() {
    initFavourites();
    super.onInit();
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
      TLoader.customToast(message: 'Product has been added to the Wishlist');
    } else {
      DLocalStorage.instance().removeData(productId);
      favourites.remove(productId);
      saveFavouritesToStorage();
      favourites.refresh();
      TLoader.customToast(message: 'Product has been removed to the Wishlist');
    }
  }

  void saveFavouritesToStorage() {
    final encodedFavourites = json.encode(favourites);
    DLocalStorage.instance().saveData('favourites', encodedFavourites);
  }

  Future<List<ProductModel>> favouriteProducts() async{
    return await ProductRepository.instance.getFavouriteProducts(favourites.keys.toList());
  }
}
