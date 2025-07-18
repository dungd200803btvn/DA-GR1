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
  final Timestamp updatedAt;
  final bool isRedeemableByPoint;
  final num? pointsToRedeem;
  //thoi diem update lan cuoi

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
    required this.isRedeemableByPoint,
    this.pointsToRedeem
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'discountValue': discountValue,
      'maxDiscount': maxDiscount,
      'minimumOrder': minimumOrder,
      'requiredPoints':requiredPoints,
      'applicableUsers': applicableUsers,
      'applicableProducts': applicableProducts,
      'applicableCategories': applicableCategories,
      'shopId': shopId,
      'brandId': brandId,
      'categoryId': categoryId,
      'startDate': startDate,
      'endDate': endDate,
      'quantity': quantity,
      'remainingQuantity': remainingQuantity,
      'claimedUsers': claimedUsers,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isRedeemableByPoint':isRedeemableByPoint,
      'pointsToRedeem':pointsToRedeem
    };
  }

  factory VoucherModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return VoucherModel(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      type: data['type'] as String,
      discountValue: data['discountValue'] as num,
      maxDiscount: data['maxDiscount'] as num?,
      minimumOrder: data['minimumOrder'] as num?,
      requiredPoints: data['requiredPoints'] as num?,
      applicableUsers: (data['applicableUsers'] as List<dynamic>?)?.cast<String>(),
      applicableProducts: (data['applicableProducts'] as List<dynamic>?)?.cast<String>(),
      applicableCategories: (data['applicableCategories'] as List<dynamic>?)?.cast<String>(),
      shopId: data['shopId'] as String?,
      brandId: data['brandId'] as String?,
      categoryId: data['categoryId'] as String?,
      startDate: data['startDate'] as Timestamp,
      endDate: data['endDate'] as Timestamp,
      quantity: data['quantity'] as int,
      remainingQuantity: data['remainingQuantity'] as int,
      claimedUsers: (data['claimedUsers'] as List<dynamic>?)?.cast<String>(),
      isActive: data['isActive'] as bool,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
      isRedeemableByPoint: data['isRedeemableByPoint'] as bool,
      pointsToRedeem: data['pointsToRedeem'] as num?
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
      isRedeemableByPoint:  this.isRedeemableByPoint,
        pointsToRedeem: this.pointsToRedeem
    );
  }
}
