import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:t_store/features/suggestion/suggest_item_model.dart';
import 'package:t_store/features/suggestion/suggestion_model.dart';
import '../shop/models/order_model.dart';

class ProductSuggestionRepository  extends GetxController{
  static ProductSuggestionRepository get instance => Get.find();
  final _firestore = FirebaseFirestore.instance;
  // Lấy gợi ý cho một sản phẩm
  Future<ProductSuggestionModel> getProductSuggestions(String productId) async {
    final doc = await _firestore.collection('productSuggestions').doc(productId).get();
    if (doc.exists) {
      return ProductSuggestionModel.fromSnapshot(doc);
    } else {
      return ProductSuggestionModel.empty(productId);
    }
  }

  Future<List<SuggestItemModel>> getSortedSuggestions(String productId) async {
    final suggestionsRef = FirebaseFirestore.instance.collection('productSuggestions').doc(productId);
    final snapshot = await suggestionsRef.get();
    if (!snapshot.exists || snapshot.data() == null) return [];
    final data = snapshot.data()!;
    final suggestedProducts = List<String>.from(data['suggestedProducts']);
    final frequencies = List<int>.from(data['frequency']);
    // Kết hợp sản phẩm với tần suất
    List<SuggestItemModel> suggestions = [];
    for (int i = 0; i < suggestedProducts.length; i++) {
      suggestions.add(SuggestItemModel(
        productId: suggestedProducts[i],
        frequency: frequencies[i],
      ));
    }
    // Sắp xếp theo tần suất giảm dần
    suggestions.sort((a, b) => b.frequency.compareTo(a.frequency));
    for(var model in suggestions){
      if (kDebugMode) {
        print("Product ID: ${model.productId}, Frequency: ${model.frequency}");
      }
    }
    return suggestions;
  }

  // Lưu gợi ý sản phẩm vào Firestore
  Future<void> saveProductSuggestions(Map<String, Map<String, int>> suggestions) async {
    final batch = _firestore.batch();
    final suggestionsRef = _firestore.collection('productSuggestions');

    suggestions.forEach((productId, relatedProducts) {
      final docRef = suggestionsRef.doc(productId);
      final suggestedProducts = relatedProducts.keys.toList();
      final frequency = relatedProducts.values.toList();
      batch.set(docRef, ProductSuggestionModel(
        productId: productId,
        suggestedProducts: suggestedProducts,
        frequency: frequency,
      ).toJson());
    });

    await batch.commit();
  }

  // Phân tích các sản phẩm thường được mua kèm
  Future<Map<String, Map<String, int>>> analyzeFrequentlyBoughtTogether(List<OrderModel> orders) async {
    final Map<String, Map<String, int>> suggestions = {};

    for (final order in orders) {
      final items = order.items;
      for (int i = 0; i < items.length; i++) {
        final productId = items[i].productId;
        if (!suggestions.containsKey(productId)) {
          suggestions[productId] = {};
        }
        for (int j = 0; j < items.length; j++) {
          if (i == j) continue;
          final relatedProductId = items[j].productId;
          final relatedProductQuantity  = items[j].quantity;
          suggestions[productId]![relatedProductId] =
              (suggestions[productId]![relatedProductId] ?? 0) + relatedProductQuantity;
        }
      }
    }

    return suggestions;
  }

  // Tạo và lưu gợi ý từ danh sách đơn hàng
  Future<void> generateAndSaveSuggestions(List<OrderModel> orders) async {
    final suggestions = await analyzeFrequentlyBoughtTogether(orders);
    await saveProductSuggestions(suggestions);
  }
}
