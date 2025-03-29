import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:app_my_app/data/repositories/authentication/authentication_repository.dart';

import '../../../features/shop/models/order_model.dart';

class OrderRepository extends   GetxController{
  static OrderRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  //get all orders related to current user
Future<List<OrderModel>> fetchUserOrders()async{
  try{
    final userId = AuthenticationRepository.instance.authUser!.uid;
    if(userId.isEmpty) throw 'Unable to find user information. Try again in few minute';
    final result = await _db.collection('User').doc(userId).collection('Orders').orderBy('orderDate',descending: true)
        .get();
    return result.docs.map((doc) {
      try {
        return OrderModel.fromSnapshot(doc);
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing order: ${doc.id}, error: $e");
        }
        return null; // Hoặc xử lý thêm nếu cần
      }
    }).whereType<OrderModel>().toList();
  }catch(e){
    if (kDebugMode) {
      print("Error fetching orders: $e");
    }
    throw 'Something went wrong while fetching  Order Information. Try again in few minute';
  }
}

//store new user order
Future<void> saveOrder(OrderModel orderModel,String userId) async{
  if (kDebugMode) {
    try{
      final data = orderModel.toJson();
      print("Saving order for userId: $userId");
      print("Order data: $data");
      await _db.collection('User').doc(userId).collection('Orders').add(orderModel.toJson());
      print("Order saved successfully!");
    }catch(e){
      print("Error saving order: $e");
      throw 'Something went wrong while saving  Order Information. Try again in few minute';
    }
  }
}

}
