import 'package:get/get.dart';
import 'package:t_store_app/data/repositories/bonus_point/daily_checkin_repository.dart';
import 'package:t_store_app/data/repositories/brands/brand_repository.dart';
import 'package:t_store_app/data/repositories/categories/category_repository.dart';
import 'package:t_store_app/data/repositories/product/product_repository.dart';
import 'package:t_store_app/data/repositories/shop/shop_repository.dart';
import 'package:t_store_app/data/repositories/user/user_repository.dart';
import 'package:t_store_app/data/repositories/vouchers/ClaimedVoucherRepository.dart';
import 'package:t_store_app/features/bonus_point/controller/daily_checkin_controller.dart';
import 'package:t_store_app/features/personalization/controllers/address_controller.dart';
import 'package:t_store_app/features/personalization/controllers/user_controller.dart';
import 'package:t_store_app/features/shop/controllers/brand_controller.dart';
import 'package:t_store_app/features/shop/controllers/product/cart_controller.dart';
import 'package:t_store_app/features/shop/controllers/product/checkout_controller.dart';
import 'package:t_store_app/features/shop/controllers/product/favourite_controller.dart';
import 'package:t_store_app/features/shop/controllers/product/shop_controller.dart';
import 'package:t_store_app/features/shop/controllers/product/variation_controller.dart';
import 'package:t_store_app/features/voucher/controllers/voucher_controller.dart';
import 'package:t_store_app/utils/helper/network_manager.dart';
import '../data/repositories/authentication/authentication_repository.dart';
import '../data/repositories/notification/notification_repository.dart';
import '../data/repositories/review/review_repository.dart';
import '../data/repositories/vouchers/VoucherRepository.dart';
import '../features/notification/controller/notification_controller.dart';
import '../features/personalization/controllers/update_name_controller.dart';
import '../features/review/controller/review_controller.dart';
import '../features/shop/controllers/product/all_products_controller.dart';
import '../features/shop/controllers/product_controller.dart';
import '../features/shop/screens/all_products/all_product_controller.dart';
import '../features/suggestion/suggestion_repository.dart';

class GeneralBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(AuthenticationRepository());
    Get.put(NetworkManager());
    Get.put(UserRepository());
    Get.put(UserController());
    Get.put(ProductRepository());
    Get.put(ProductSuggestionRepository());
    Get.put(ProductController());
    Get.put(AllProductsController());
    Get.put(AllProductController());
    Get.put(BrandRepository());
    Get.put(BrandController());
    Get.put(CategoryRepository());
    Get.put(ShopRepository());
    Get.put(ShopController());
    Get.put(FavouritesController());
    Get.put(VariationController());
    Get.put(CartController());
    Get.put(UpdateNameController());
    Get.put(CheckoutController());
    Get.put(AddressController());
    Get.put(VoucherRepository());
    Get.put(VoucherController());
    Get.put(ClaimedVoucherRepository());
    Get.put(NotificationRepository());
    Get.put(NotificationController());
    NotificationController.instance.updateUserNotifications();
    Get.put(ReviewRepository());
    Get.put(WriteReviewScreenController());
    Get.put(DailyCheckInRepository());
    Get.put(DailyCheckinController());
  }
}
