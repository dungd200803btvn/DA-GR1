import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String image;
  String parentId;
  bool isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.parentId = '',
    required this.isFeatured,
  });
  static CategoryModel empty() => CategoryModel(id: "", name: "", image: "", isFeatured: false);
  //convert to Json
  Map<String,dynamic> toJson(){
    return{
      'Name': name,
      'Image':image,
      'ParentId':parentId,
      'IsFeatured':isFeatured,
    };
  }
  // Factory constructor từ JSON trả về từ API Node.js
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['Name'] ?? '',
      image: json['categoryImage'] ?? '', // Nếu API không trả về Image, có thể gán chuỗi rỗng
      isFeatured: json['IsFeatured'] ?? false,
      parentId: json['ParentId'] ?? '',
    );
  }


  //another constructor use factory keyword
  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){
    if(document.data()!=null){
      final data = document.data()!;
      //map json to model
      return CategoryModel(
          id: document.id,
          name: data['Name'] ?? " ",
          image: data['Image'] ?? " ",
          isFeatured: data['IsFeatured'] ?? false,
          parentId: data['ParentId'] ?? " ");
    }else{
      return CategoryModel.empty();
    }
  }
}
