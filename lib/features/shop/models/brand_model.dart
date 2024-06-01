class BrandModel {
  String id;
  String name;
  String image;
  bool? isFeatured;
  int? productsCount;

  BrandModel({
    required this.id,
    required this.name,
    required this.image,
    this.isFeatured,
    this.productsCount,
  });

  // Empty constructor
  static BrandModel empty() => BrandModel(id: '', name: '', image: '');

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'ProductsCount': productsCount,
      'IsFeatured': isFeatured,
    };
  }

  factory BrandModel.fromJson(Map<String, dynamic> data) {
    if (data.isEmpty) return BrandModel.empty();

    // Try parsing productsCount to an integer, handle potential errors
    int? parsedProductsCount;
    try {
      parsedProductsCount = data['ProductsCount'] != null ? int.parse(data['ProductsCount'].toString()) : null;
    } catch (e) {
      // Handle parsing error (e.g., print a warning)
      print('Lỗi khi chuyển đổi productsCount thành số nguyên (int). Giá trị mặc định 0 sẽ được sử dụng.');
    }

    return BrandModel(
      id: data['Id'] ?? '',
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      productsCount: parsedProductsCount ?? 0, // Use default 0 if parsing fails
      isFeatured: data['IsFeatured'] ?? false,
    );
  }
}
