import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../utils/singleton/user_singleton.dart';
import '../../suggestion/service/RecommendationService.dart';
import '../models/product_model.dart';

class RecommendationController extends GetxController {
  static RecommendationController get instance => Get.find();

  final recommendedProducts = <ProductModel>[].obs;
  final isLoading = false.obs;
  final isLoaded = false.obs;

  Future<void> fetchRecommendations(String userId) async {
    if (isLoaded.value) return; // đã có rồi thì bỏ qua
    try {
      isLoading.value = true;
      final products = await RecommendationService.instance.getRecommendedProducts(userId: userId);
      recommendedProducts.assignAll(products);
      isLoaded.value = true;
    } catch (e) {
      print("❌ Lỗi khi load gợi ý: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
