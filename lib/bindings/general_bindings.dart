import 'package:get/get.dart';
import 'package:t_store/data/repositories/user/user_repository.dart';
import 'package:t_store/data/repositories/vouchers/ClaimedVoucherRepository.dart';
import 'package:t_store/features/personalization/controllers/address_controller.dart';
import 'package:t_store/features/personalization/controllers/user_controller.dart';
import 'package:t_store/features/shop/controllers/product/cart_controller.dart';
import 'package:t_store/features/shop/controllers/product/checkout_controller.dart';
import 'package:t_store/features/shop/controllers/product/variation_controller.dart';
import 'package:t_store/features/voucher/controllers/voucher_controller.dart';
import 'package:t_store/utils/helper/network_manager.dart';
import '../data/repositories/notification/notification_repository.dart';
import '../data/repositories/vouchers/VoucherRepository.dart';
import '../features/notification/controller/notification_controller.dart';
import '../features/personalization/controllers/update_name_controller.dart';

class GeneralBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(UserRepository());
    Get.put(UserController());
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
  }
}
