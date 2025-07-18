import 'package:cloud_firestore/cloud_firestore.dart';
class BrandCategoryModel {
  final String brandId;
  final String categoryId;

  BrandCategoryModel({required this.brandId, required this.categoryId});
  Map<String,dynamic> toJson(){
    return{
      'brandId':brandId,
      'categoryId':categoryId,
    };
  }
  factory BrandCategoryModel.fromSnapshot(DocumentSnapshot snapshot){
    final data = snapshot.data() as Map<String,dynamic>;
    return BrandCategoryModel(
      brandId: data['brandId'] as String,
      categoryId: data['categoryId'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BrandCategoryModel &&
              runtimeType == other.runtimeType &&
              brandId == other.brandId &&
              categoryId == other.categoryId;

  @override
  int get hashCode => brandId.hashCode ^ categoryId.hashCode;

  @override
  String toString() {
    return 'BrandCategoryModel{brandId: $brandId, categoryId: $categoryId}';
  }
}
