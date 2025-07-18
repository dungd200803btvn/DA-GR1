class FeeModel {
  final int mainService;
  final int insurance;
  final int codFee;
  final int stationDo;
  final int stationPu;
  final int returnFee;
  final int r2s;
  final int returnAgain;
  final int coupon;
  final int documentReturn;
  final int doubleCheck;
  final int doubleCheckDeliver;
  final int pickRemoteAreasFee;
  final int deliverRemoteAreasFee;
  final int pickRemoteAreasFeeReturn;
  final int deliverRemoteAreasFeeReturn;
  final int codFailedFee;

  FeeModel({
    required this.mainService,
    required this.insurance,
    required this.codFee,
    required this.stationDo,
    required this.stationPu,
    required this.returnFee,
    required this.r2s,
    required this.returnAgain,
    required this.coupon,
    required this.documentReturn,
    required this.doubleCheck,
    required this.doubleCheckDeliver,
    required this.pickRemoteAreasFee,
    required this.deliverRemoteAreasFee,
    required this.pickRemoteAreasFeeReturn,
    required this.deliverRemoteAreasFeeReturn,
    required this.codFailedFee,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      mainService: json['main_service'] ?? 0,
      insurance: json['insurance'] ?? 0,
      codFee: json['cod_fee'] ?? 0,
      stationDo: json['station_do'] ?? 0,
      stationPu: json['station_pu'] ?? 0,
      returnFee: json['return'] ?? 0,
      r2s: json['r2s'] ?? 0,
      returnAgain: json['return_again'] ?? 0,
      coupon: json['coupon'] ?? 0,
      documentReturn: json['document_return'] ?? 0,
      doubleCheck: json['double_check'] ?? 0,
      doubleCheckDeliver: json['double_check_deliver'] ?? 0,
      pickRemoteAreasFee: json['pick_remote_areas_fee'] ?? 0,
      deliverRemoteAreasFee: json['deliver_remote_areas_fee'] ?? 0,
      pickRemoteAreasFeeReturn: json['pick_remote_areas_fee_return'] ?? 0,
      deliverRemoteAreasFeeReturn: json['deliver_remote_areas_fee_return'] ?? 0,
      codFailedFee: json['cod_failed_fee'] ?? 0,
    );
  }
}

class ShippingOrderModel {
  final String orderCode;
  final FeeModel fee;
  final int totalFee;
  final String expectedDeliveryTime;
  final String messageDisplay;

  ShippingOrderModel({
    required this.orderCode,
    required this.fee,
    required this.totalFee,
    required this.expectedDeliveryTime,
    required this.messageDisplay,
  });

  factory ShippingOrderModel.fromJson(Map<String, dynamic> json) {
    return ShippingOrderModel(
      orderCode: json['data']['order_code'] ?? '',
      fee: FeeModel.fromJson(json['data']['fee'] ?? {}),
      totalFee: json['data']['total_fee'] ?? 0,
      expectedDeliveryTime: json['data']['expected_delivery_time'] ?? '',
      messageDisplay: json['message_display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_code': orderCode,
      'fee': fee,
      'total_fee': totalFee,
      'expected_delivery_time': expectedDeliveryTime,
      'message_display': messageDisplay,
    };
  }
}
