import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String title;
  final String description;
  final String type; // fixed_discount, percentage_discount, free_shipping, ...
  final num discountValue;
  final num? maxDiscount; // Áp dụng cho percentage_discount
  final num? minimumOrder;
  final num? requiredPoints;//gia tri don hang toi thieu co the ap dung
  final List<String>? applicableUsers; // null = Áp dụng cho tất cả user
  final List<String>? applicableProducts; // null = Áp dụng cho tất cả sản phẩm
  final List<String>? applicableCategories;
  final String? shopId;
  final String? brandId;
  final String? categoryId;
  final Timestamp startDate;
  final Timestamp endDate;
  final int quantity; //so luong phat hanh
  final int remainingQuantity; //so luong con lai
  final List<String>? claimedUsers; //nguoi da nhan
  final bool isActive; //trang thai hoat dong
  final Timestamp createdAt; //thoi diem tao
  final Timestamp updatedAt; //thoi diem update lan cuoi

  VoucherModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.discountValue,
    this.maxDiscount,
    this.minimumOrder,
    this.requiredPoints,
    this.applicableUsers,
    this.applicableProducts,
    this.applicableCategories,
    this.shopId,
    this.brandId,
    this.categoryId,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.remainingQuantity,
    this.claimedUsers,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'discount_value': discountValue,
      'max_discount': maxDiscount,
      'minimum_order': minimumOrder,
      'required_points':requiredPoints,
      'applicable_users': applicableUsers,
      'applicable_products': applicableProducts,
      'applicable_categories': applicableCategories,
      'shopId': shopId,
      'brandId': brandId,
      'categoryId': categoryId,
      'start_date': startDate,
      'end_date': endDate,
      'quantity': quantity,
      'remaining_quantity': remainingQuantity,
      'claimed_users': claimedUsers,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory VoucherModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return VoucherModel(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      type: data['type'] as String,
      discountValue: data['discount_value'] as num,
      maxDiscount: data['max_discount'] as num?,
      minimumOrder: data['minimum_order'] as num?,
      requiredPoints: data['required_points'] as num?,
      applicableUsers: (data['applicable_users'] as List<dynamic>?)?.cast<String>(),
      applicableProducts: (data['applicable_products'] as List<dynamic>?)?.cast<String>(),
      applicableCategories: (data['applicable_categories'] as List<dynamic>?)?.cast<String>(),
      shopId: data['shopId'] as String?,
      brandId: data['brandId'] as String?,
      categoryId: data['categoryId'] as String?,
      startDate: data['start_date'] as Timestamp,
      endDate: data['end_date'] as Timestamp,
      quantity: data['quantity'] as int,
      remainingQuantity: data['remaining_quantity'] as int,
      claimedUsers: (data['claimed_users'] as List<dynamic>?)?.cast<String>(),
      isActive: data['is_active'] as bool,
      createdAt: data['created_at'] as Timestamp,
      updatedAt: data['updated_at'] as Timestamp,
    );
  }

  // Thêm phương thức copyWith
  VoucherModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    num? discountValue,
    num? maxDiscount,
    num? minimumOrder,
    num? requiredPoints,
    List<String>? applicableUsers,
    List<String>? applicableProducts,
    List<String>? applicableCategories,
    String? shopId,
    String? brandId,
    String? categoryId,
    Timestamp? startDate,
    Timestamp? endDate,
    int? quantity,
    int? remainingQuantity,
    List<String>? claimedUsers,
    bool? isActive,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return VoucherModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      discountValue: discountValue ?? this.discountValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      applicableUsers: applicableUsers ?? this.applicableUsers,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      shopId: shopId?? this.shopId,
      brandId: brandId?? this.brandId,
      categoryId: categoryId?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      quantity: quantity ?? this.quantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      claimedUsers: claimedUsers ?? this.claimedUsers,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
