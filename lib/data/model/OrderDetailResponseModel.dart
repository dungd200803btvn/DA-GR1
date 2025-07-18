
class OrderDetailModel {
  final String fromWardCode;
  final int fromDistrictId;
  final String toWardCode;
  final int toDistrictId;
  final String sortCode;
  final double insuranceValue;
  final double orderValue;
  final int pickStationId;
  final String clientOrderCode;
  final String pickupTime;
  final String coupon;
  final String status;
  final String internalProcessStatus;
  final String internalProcessType;
  final int pickWarehouseId;
  final int deliverWarehouseId;
  final int currentWarehouseId;
  final int returnWarehouseId;
  final int nextWarehouseId;
  final int currentTransportWarehouseId;
  final String leadtime;
  final String leadtimeFromEstimateDate;
  final String leadtimeToEstimateDate;
  final String orderDate;

  OrderDetailModel({
    required this.fromWardCode,
    required this.fromDistrictId,
    required this.toWardCode,
    required this.toDistrictId,
    required this.sortCode,
    required this.insuranceValue,
    required this.orderValue,
    required this.pickStationId,
    required this.clientOrderCode,
    required this.pickupTime,
    required this.coupon,
    required this.status,
    required this.internalProcessStatus,
    required this.internalProcessType,
    required this.pickWarehouseId,
    required this.deliverWarehouseId,
    required this.currentWarehouseId,
    required this.returnWarehouseId,
    required this.nextWarehouseId,
    required this.currentTransportWarehouseId,
    required this.leadtime,
    required this.leadtimeFromEstimateDate,
    required this.leadtimeToEstimateDate,
    required this.orderDate,
  });

  // Ánh xạ từ DocumentSnapshot
  factory OrderDetailModel.fromJson(Map<String, dynamic>  data) {
    return OrderDetailModel(
      fromWardCode: data['data']['from_ward_code'] ?? '',
      fromDistrictId: data['data']['from_district_id'] ?? 0,
      toWardCode: data['data']['to_ward_code'] ?? '',
      toDistrictId: data['data']['to_district_id'] ?? 0,
      sortCode: data['data']['sort_code'] ?? '',
      insuranceValue: (data['data']['insurance_value'] ?? 0).toDouble(),
      orderValue: (data['data']['order_value'] ?? 0).toDouble(),
      pickStationId: data['data']['pick_station_id'] ?? 0,
      clientOrderCode: data['data']['client_order_code'] ?? '',
      pickupTime: data['data']['pickup_time'] ?? '',
      coupon: data['data']['coupon'] ?? '',
      status: data['data']['status'] ?? '',
      internalProcessStatus: data['data']['internal_process']?['status'] ?? '',
      internalProcessType: data['data']['internal_process']?['type'] ?? '',
      pickWarehouseId: data['data']['pick_warehouse_id'] ?? 0,
      deliverWarehouseId: data['data']['deliver_warehouse_id'] ?? 0,
      currentWarehouseId: data['data']['current_warehouse_id'] ?? 0,
      returnWarehouseId: data['data']['return_warehouse_id'] ?? 0,
      nextWarehouseId: data['data']['next_warehouse_id'] ?? 0,
      currentTransportWarehouseId: data['data']['current_transport_warehouse_id'] ?? 0,
      leadtime: data['data']['leadtime'] ?? '',
      leadtimeFromEstimateDate: data['data']['leadtime_order']?['from_estimate_date'] ?? '',
      leadtimeToEstimateDate: data['data']['leadtime_order']?['to_estimate_date'] ?? '',
      orderDate: data['data']['order_date'] ?? '',
    );
    }

  factory OrderDetailModel.fromSnapshot(Map<String, dynamic>  data) {
    return OrderDetailModel(
      fromWardCode: data['from_ward_code'] ?? '',
      fromDistrictId: data['from_district_id'] ?? 0,
      toWardCode: data['to_ward_code'] ?? '',
      toDistrictId: data['to_district_id'] ?? 0,
      sortCode: data['sort_code'] ?? '',
      insuranceValue: (data['insurance_value'] ?? 0).toDouble(),
      orderValue: (data['order_value'] ?? 0).toDouble(),
      pickStationId: data['pick_station_id'] ?? 0,
      clientOrderCode: data['client_order_code'] ?? '',
      pickupTime: data['pickup_time'] ?? '',
      coupon: data['coupon'] ?? '',
      status: data['status'] ?? '',
      internalProcessStatus: data['internal_process']?['status'] ?? '',
      internalProcessType: data['internal_process']?['type'] ?? '',
      pickWarehouseId: data['pick_warehouse_id'] ?? 0,
      deliverWarehouseId: data['deliver_warehouse_id'] ?? 0,
      currentWarehouseId: data['current_warehouse_id'] ?? 0,
      returnWarehouseId: data['return_warehouse_id'] ?? 0,
      nextWarehouseId: data['next_warehouse_id'] ?? 0,
      currentTransportWarehouseId: data['current_transport_warehouse_id'] ?? 0,
      leadtime: data['leadtime'] ?? '',
      leadtimeFromEstimateDate: data['leadtime_order']?['from_estimate_date'] ?? '',
      leadtimeToEstimateDate: data['leadtime_order']?['to_estimate_date'] ?? '',
      orderDate: data['order_date'] ?? '',
    );
  }

  // Chuyển về JSON (nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'from_ward_code': fromWardCode,
      'from_district_id': fromDistrictId,
      'to_ward_code': toWardCode,
      'to_district_id': toDistrictId,
      'sort_code': sortCode,
      'insurance_value': insuranceValue,
      'order_value': orderValue,
      'pick_station_id': pickStationId,
      'client_order_code': clientOrderCode,
      'pickup_time': pickupTime,
      'coupon': coupon,
      'status': status,
      'internal_process': {
        'status': internalProcessStatus,
        'type': internalProcessType,
      },
      'pick_warehouse_id': pickWarehouseId,
      'deliver_warehouse_id': deliverWarehouseId,
      'current_warehouse_id': currentWarehouseId,
      'return_warehouse_id': returnWarehouseId,
      'next_warehouse_id': nextWarehouseId,
      'current_transport_warehouse_id': currentTransportWarehouseId,
      'leadtime': leadtime,
      'leadtime_order': {
        'from_estimate_date': leadtimeFromEstimateDate,
        'to_estimate_date': leadtimeToEstimateDate,
      },
      'order_date': orderDate,
    };
  }
}
