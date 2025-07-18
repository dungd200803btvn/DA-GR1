class CartItemModel {
  String productId;
  String title;
  String? category;
  double _price;
  String? image;
  int quantity;
  String variationId;
  String? brandName;
  Map<String, String>? selectedVariation;

  CartItemModel({required this.productId,
    this.title = ' ',
    this.category ,
    double price = 0.0,
    this.image,
    required this.quantity,
    this.variationId = ' ',
    this.brandName,
    this.selectedVariation}): _price = price;

  static CartItemModel empty() => CartItemModel(productId: '', quantity: 0);
  /// Getter cho price
  double get price => _price;

  /// Setter cho price
  set price(double newPrice) {
    if (newPrice >= 0) {
      _price = newPrice;
    } else {
      throw ArgumentError('Price cannot be negative');
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'category':category,
      'price': _price,
      'image': image,
      'quantity': quantity,
      'variationId': variationId,
      'brandName': brandName,
      'selectedVariation': selectedVariation
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json){
    return CartItemModel(
        productId: json['productId'],
        title: json['title'],
        category: json['category'],
        price: json['price']?.toDouble(),
        image: json['image'],
        quantity: json['quantity'],
        variationId: json['variationId'],
        brandName: json['brandName'],
        selectedVariation: json['selectedVariation'] !=null ? Map<String,String>.from(json['selectedVariation']):null,
       );
  }
}
