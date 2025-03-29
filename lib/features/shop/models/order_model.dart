import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:t_store_app/features/personalization/models/address_model.dart';
import 'package:t_store_app/utils/constants/enums.dart';
import 'package:t_store_app/utils/formatter/formatter.dart';
import 'package:t_store_app/utils/helper/helper_function.dart';
import '../../../data/model/OrderDetailResponseModel.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModel? address;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;
  final OrderDetailModel? orderDetail;
  final bool notificationSent;

  OrderModel(
        {required this.id,
        this.userId = '',
        required this.status,
        required this.totalAmount,
        required this.orderDate,
        this.paymentMethod = 'Paypal',
        this.address,
        this.deliveryDate,
        required this.items,
        this.orderDetail,
        this.notificationSent = false});

  String get formattedOrderDate => DFormatter.FormattedDate1(orderDate);

  String get formattedDeliveryDate =>
      deliveryDate != null ? DFormatter.FormattedDate1(deliveryDate!) : " ";

  String get orderStatusText => status == OrderStatus.delivered
      ? "Delivered"
      : status == OrderStatus.shipped
          ? "Shipment on the way"
          : 'Processing';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "userId": userId,
      "status": status.toString(),
      "totalAmount": totalAmount,
      "orderDate": orderDate,
      "paymentMethod": paymentMethod,
      "address": address?.toJson(),
      "deliveryDate": deliveryDate,
      'items': items.map((item) => item.toJson()).toList(),
      'orderDetail': orderDetail?.toJson(),
      "notificationSent": notificationSent
    };
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OrderModel(
        id: data['id'] as String,
        userId: data['userId'] as String,
        status: OrderStatus.values
            .firstWhere((element) => element.toString() == data['status']),
        totalAmount: data['totalAmount'] as double,
        orderDate: (data['orderDate'] as Timestamp).toDate(),
        paymentMethod: data['paymentMethod'] as String,
        address: AddressModel.fromMap(data['address'] as Map<String, dynamic>),
        deliveryDate: data['deliveryDate'] == null
            ? null
            : (data['deliveryDate'] as Timestamp).toDate(),
        items: (data['items'] as List<dynamic>)
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        orderDetail: data['orderDetail'] != null
          ? OrderDetailModel.fromSnapshot(data['orderDetail'] as Map<String, dynamic>)
          : null,
      notificationSent: data['notificationSent'] as bool);
  }
}
