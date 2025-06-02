import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String image;
  String parentId;
  bool isFeatured;
  int? productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.parentId = '',
    required this.isFeatured,
    this.productCount
  });
  static CategoryModel empty() => CategoryModel(id: "", name: "", image: "", isFeatured: false);
  //convert to Json
  Map<String,dynamic> toJson(){
    return{
      'name': name,
      'image':image,
      'parentId':parentId,
      'isFeatured':isFeatured,
    };
  }
  // Factory constructor từ JSON trả về từ API Node.js
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['categoryImage'] ?? '', // Nếu API không trả về Image, có thể gán chuỗi rỗng
      isFeatured: json['isFeatured'] ?? false,
      parentId: json['parentId'] ?? '',
    );
  }

  factory CategoryModel.fromMap(String catId,Map<String, dynamic> json,String? image, int? productCount) {
    return CategoryModel(
      id: catId,
      name: json['name'] ?? '',
      image: image ?? '', // Nếu API không trả về Image, có thể gán chuỗi rỗng
      isFeatured: json['isFeatured'] ?? false,
      parentId: json['parentId'] ?? '',
      productCount: productCount
    );
  }


  //another constructor use factory keyword
  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){
    if(document.data()!=null){
      final data = document.data()!;
      //map json to model
      return CategoryModel(
          id: document.id,
          name: data['name'] ?? " ",
          image: data['image'] ?? " ",
          isFeatured: data['isFeatured'] ?? false,
          parentId: data['parentId'] ?? " ");
    }else{
      return CategoryModel.empty();
    }
  }
}
