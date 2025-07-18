import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../utils/helper/logger.dart';

class ShippingOrderService {
  final Dio _dio = Dio();
  ShippingOrderService() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.interceptors.add(PrettyDioLogger(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: false,
    ));
  }

  Future<Map<String, dynamic>> createShippingOrder(Map<String, dynamic> data) async {
    const url =
        'https://online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/create';
    try {
      final response = await _dio.post(
        url,
        data: jsonEncode(data),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ShopId': '5527257',
            'Token': '192fb046-bb88-11ef-96cc-4a5557a70795',
          },
        ),
      );
      // Debug thông tin response
      return response.data;
    } catch (e) {
      DLoggerHelper.error('Error in createShippingOrder: $e');
      rethrow; // Ném lỗi để gọi hàm xử lý bên ngoài
    }
  }

  Future<Map<String, dynamic>> getOrderDetail(String orderCode) async {
    const url =
        'https://online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/detail';
    try {
      final data = {
        "order_code": orderCode
      };
      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Token': '192fb046-bb88-11ef-96cc-4a5557a70795',
          },
        ),
      );
      // Debug thông tin response
      return response.data;
    } catch (e) {
      DLoggerHelper.error('Error in getOrderDetail: $e');
      rethrow; // Ném lỗi để gọi hàm xử lý bên ngoài
    }
  }
}
