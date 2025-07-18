class SuggestItemModel {
  final String productId;
  final int frequency;

  SuggestItemModel({
    required this.productId,
    required this.frequency,
  });

  factory SuggestItemModel.fromJson(Map<String, dynamic> json) {
    return SuggestItemModel(
      productId: json['productId'],
      frequency: json['frequency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'frequency': frequency,
    };
  }
}
