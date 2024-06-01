import 'package:cloud_firestore/cloud_firestore.dart';

class ProductAttributeModel{
  String? name;
  final List<String>? values;

  ProductAttributeModel({this.name, this.values});
  Map<String, dynamic>  toJson(){
    return {
      'Name':name,
      "Values":values
    };
  }


  static ProductAttributeModel empty() => ProductAttributeModel();
  factory ProductAttributeModel.fromJson(Map<String,dynamic> document){

      final data = document;
      if(data.isEmpty) return ProductAttributeModel.empty();
      return ProductAttributeModel(
          name: data.containsKey('Name')? data['Name']: '',
          values:  List<String>.from(data['Values']));
  }
}