import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel{
  String id;
  String name;
  int? productCount;
  ShopModel({required this.id, required this.name, this.productCount});
  static ShopModel empty() => ShopModel(id: "", name: "");
  factory ShopModel.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){
    if(document.data()!=null){
      final data = document.data()!;
      //map json to model
      return ShopModel(
          id: document.id,
          name: data['name'] ?? " ");
    }else{
      return ShopModel.empty();
    }
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      productCount: json['productCount']
    );
  }

  Map<String,dynamic> toJson(){
    return{
      'id': id,
      'name':name,
    };
  }
}
