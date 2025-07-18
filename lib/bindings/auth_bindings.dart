import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import '../data/repositories/user/user_repository.dart';
import '../features/authentication/controller/login/login_controller.dart';
import '../features/personalization/controllers/user_controller.dart';
import '../utils/helper/network_manager.dart';

class AuthBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(UserRepository());
    Get.put(UserController());
    Get.put(LoginController());
  }

  }