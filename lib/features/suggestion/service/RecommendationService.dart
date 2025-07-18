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
    final url = Uri.parse(recommenderUrl);
    final body = {
      "user_id": userId,
      "top_k": top_recommend,
      if (productId != null) "product_id": productId,
    };

    print("📤 Đang gửi request đến API:");
    print("- URL: $url");
    print("- Body: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("✅ Nhận được phản hồi từ server:");
      print("- Status code: ${response.statusCode}");
      print("- Body: ${response.body}");

      if (response.statusCode != 200) {
        throw "Lỗi server: ${response.statusCode} - ${response.reasonPhrase}";
      }

      final List<dynamic> data = jsonDecode(response.body);
// Lọc dữ liệu hợp lệ
      final filteredData = data.where((item) {
        final hasId = item['product_id'] != null && (item['product_id'] as String).isNotEmpty;
        if (!hasId) print("⚠️ Bỏ qua item vì thiếu product_id: $item");
        return hasId;
      }).toList();


      final List<String> productIds = filteredData
          .map<String>((item) => item['product_id'] as String)
          .toList();

      // print("📦 Danh sách product_id nhận được: $productIds");

      final productFutures = productIds.map((id) async {
        try {
          final product = await productRepository.getProductById(id);
          if (product == null) {
            print("⚠️ Không tìm thấy sản phẩm với id: $id");
          }
          return product;
        } catch (e) {
          print("❌ Lỗi khi lấy sản phẩm $id: $e");
          return null;
        }
      });

      final productModels = await Future.wait(productFutures, eagerError: false);
      final validProducts = productModels.where((p) => p != null).cast<ProductModel>().toList();

      return validProducts;
    } catch (e) {
      print("❌ Lỗi khi gọi API hoặc xử lý dữ liệu: $e");
      rethrow;
    }
  }

}
