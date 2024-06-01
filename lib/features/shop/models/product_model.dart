
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_store/features/shop/models/brand_model.dart';
import 'package:t_store/features/shop/models/product_attribute_model.dart';
import 'package:t_store/features/shop/models/product_variation_model.dart';
class ProductModel{
  String id;
  int stock;
  String? sku;
  double price;
  String title;
  DateTime? date;
  double salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? description;
  String? categoryId;
  List<String>? images;
  String productType;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;

  ProductModel(
  {
  required this.id,
  required this.stock,
  this.sku,
  required  this.price,
  required this.title,
  this.date,
  this.salePrice =0.0,
  required  this.thumbnail,
  this.isFeatured,
  this.brand,
  this.description,
  this.categoryId,
  this.images,
  required this.productType,
  this.productAttributes,
  this.productVariations
});

static ProductModel empty()=> ProductModel(id: '', stock: 0, price: 0.0, title: '', thumbnail: '', productType: '');

  Map<String, dynamic> toJson() {
  return {
    'SKU': sku,
    'Title': title,
    'Stock': stock,
    'Price': price,
    'Images': images ?? [],
    'Thumbnail': thumbnail,
    'SalePrice': salePrice,
    'IsFeatured':isFeatured,
    'CategoryId':categoryId,
    'Brand':brand,
    'Description':description,
    'ProductType':productType,
    'ProductAttributes':productAttributes!=null ? productAttributes!.map((e) => e.toJson()).toList():[],
    'ProductVariations':productVariations!=null ? productVariations!.map((e) => e.toJson()).toList():[],
  };
}

factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> documentSnapshot ){
  if(documentSnapshot.data()!=null){
    final data =documentSnapshot.data()!;
    return ProductModel(id: documentSnapshot.id,
      sku:  data['Title'],
      title: data['SKU'],
      stock: data['Stock'] ?? 0,
      isFeatured: data['IsFeatured'] ?? false,
      price: double.parse((data['Price']?? 0.0).toString()),
      salePrice: double.parse((data['SalePrice']?? 0.0).toString()),
      thumbnail: data['Thumbnail']?? '',
      categoryId: data['CategoryId']?? '',
      description: data['Description']?? '',
      productType:  data['ProductType']?? '',
      brand: data['Brand'] != null ? BrandModel.fromJson(data['Brand']) : null,
      images: data['Images'] !=null ? List<String>.from(data['Images']):[],
      productAttributes: data['ProductAttributes'] != null
          ? (data['ProductAttributes'] as List<dynamic>)
          .map((e) => ProductAttributeModel.fromJson(e))
          .toList()
          : [],
      productVariations: data['ProductVariations'] != null
          ? (data['ProductVariations'] as List<dynamic>)
          .map((e) => ProductVariationModel.fromJson(e))
          .toList()
          : [],
    );
  }else{
    return ProductModel.empty();
  }

}



}

