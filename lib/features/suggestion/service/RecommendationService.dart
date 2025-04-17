import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/repositories/product/product_repository.dart';
import '../../../utils/constants/api_constants.dart';
import '../../shop/models/product_model.dart';

class RecommendationService {
  // ✅ Singleton instance
  static final RecommendationService instance = RecommendationService._internal();
  // ✅ Factory constructor
  factory RecommendationService() => instance;
  // ✅ Internal constructor
  RecommendationService._internal();
  // ✅ Firebase
  final productRepository  = ProductRepository.instance;
  /// API call to get recommended products
  Future<List<ProductModel>> getRecommendedProducts({
    required String userId,
    String? productId,
  }) async {
    final url = Uri.parse(recommendUrl);
    final body = {
      "user_id": userId,
      "top_k": top_recommend,
      if (productId != null) "product_id": productId,
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw "Lỗi server: ${response.statusCode} - ${response.reasonPhrase}";
      }

      final List<dynamic> data = jsonDecode(response.body);
      final List<String> productIds = data
          .map<String>((item) => item['product_id'] as String)
          .toList();
      final productFutures = productIds.map((id) => productRepository.getProductById(id));
      final productModels = await Future.wait(productFutures, eagerError: false);
      return productModels.whereType<ProductModel>().toList();
    } catch (e) {
      print("Lỗi khi gọi API hoặc xử lý dữ liệu: $e");
      rethrow;
    }
  }
}
