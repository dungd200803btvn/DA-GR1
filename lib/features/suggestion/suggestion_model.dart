import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSuggestionModel {
  final String productId;
  final List<String> suggestedProducts;
  final List<int> frequency;

  ProductSuggestionModel({
    required this.productId,
    required this.suggestedProducts,
    required this.frequency,
  });

  // Tạo model rỗng
  static ProductSuggestionModel empty(String productId) => ProductSuggestionModel(
    productId: productId,
    suggestedProducts: [],
    frequency: [],
  );

  // Chuyển model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'suggestedProducts': suggestedProducts,
      'frequency': frequency,
    };
  }

  // Chuyển từ Firestore DocumentSnapshot sang model
  factory ProductSuggestionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data != null) {
      return ProductSuggestionModel(
        productId: doc.id,
        suggestedProducts: List<String>.from(data['suggestedProducts'] ?? []),
        frequency: List<int>.from(data['frequency'] ?? []),
      );
    } else {
      return ProductSuggestionModel.empty(doc.id);
    }
  }
}
