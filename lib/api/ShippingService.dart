import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../utils/helper/logger.dart';

class ShippingOrderService {
  final Dio _dio = Dio();

  Future<void> createShippingOrder() async {
    _dio.options.connectTimeout = Duration(seconds: 10);
    _dio.options.receiveTimeout = Duration(seconds: 10);
    _dio.interceptors.add(PrettyDioLogger(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: false,
    ));

    const url = 'https://dev-online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/create';

    // Dữ liệu cần gửi
    final data = {
      "payment_type_id": 2,
      "note": "Tintest 123",
      "required_note": "KHONGCHOXEMHANG",
      "return_phone": "0332190158",
      "return_address": "39 NTT",
      "return_ward_code": "",
      "client_order_code": "",
      "from_name": "TinTest124",
      "from_phone": "0987654321",
      "from_address": "72 Thành Thái, Phường 14, Quận 10, Hồ Chí Minh, Vietnam",
      "from_ward_name": "Phường 14",
      "from_district_name": "Quận 10",
      "from_province_name": "HCM",
      "to_name": "TinTest124",
      "to_phone": "0987654321",
      "to_address": "72 Thành Thái, Phường 14, Quận 10, Hồ Chí Minh, Vietnam",
      "to_ward_name": "Phường 14",
      "to_district_name": "Quận 10",
      "to_province_name": "HCM",
      "cod_amount": 200000,
      "content": "Theo New York Times",
      "weight": 200,
      "length": 1,
      "width": 19,
      "height": 10,
      "cod_failed_amount": 2000,
      "pick_station_id": 1444,
      "deliver_station_id": null,
      "insurance_value": 100,
      "service_id": 0,
      "service_type_id": 2,
      "coupon": null,
      "pickup_time": 1692840132,
      "pick_shift": [2],
      "items": [
        {
          "name": "Áo Polo",
          "code": "Polo123",
          "quantity": 1,
          "price": 200000,
          "length": 12,
          "width": 12,
          "weight": 1200,
          "height": 12,
          "category": {"level1": "Áo"}
        }
      ]
    };

    try {
      DLoggerHelper.debug('Hàm createShippingOrder được gọi');
      DLoggerHelper.debug('Request URL: $url');
      DLoggerHelper.debug('Request headers: ${_dio.options.headers}');
      DLoggerHelper.debug('Request body: $data');

      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ShopId': '195166',
            'Token': 'be0a65bb-986b-11ef-8e53-0a00184fe694',
          },
        ),
      );

      if (response.statusCode == 200) {
        DLoggerHelper.info('[DEBUG] Tạo đơn hàng thành công: ${response.data}');
      } else {
        DLoggerHelper.warning('[DEBUG] Lỗi khi tạo đơn hàng: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        DLoggerHelper.error('[DEBUG] DioError xảy ra:');
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            DLoggerHelper.error('⏰ Kết nối bị timeout: ${e.message}');
            break;
          case DioExceptionType.receiveTimeout:
            DLoggerHelper.error('⏰ Hết thời gian chờ phản hồi: ${e.message}');
            break;
          case DioExceptionType.badResponse:
            DLoggerHelper.error('📩 Server trả về lỗi: ${e.response?.statusCode}');
            DLoggerHelper.error('🔍 Response data: ${e.response?.data}');
            break;
          case DioExceptionType.cancel:
            DLoggerHelper.error('🚫 Request bị hủy: ${e.message}');
            break;
          case DioExceptionType.unknown:
            DLoggerHelper.error('🔌 Lỗi khác (ví dụ mất mạng): ${e.message}');
            break;
          case DioExceptionType.sendTimeout:
            DLoggerHelper.error('🔌 Lỗi sendTimeout: ${e.message}');
            break;
          case DioExceptionType.badCertificate:
            DLoggerHelper.error('🔌 Lỗi badCertificate: ${e.message}');
            break;
          case DioExceptionType.connectionError:
            DLoggerHelper.error('🔌 Lỗi connectionError: ${e.message}');
            break;
        }
        DLoggerHelper.debug('🛠 Request URL: ${e.requestOptions.uri}');
        DLoggerHelper.debug('🛠 Request headers: ${e.requestOptions.headers}');
        DLoggerHelper.debug('🛠 Request data: ${e.requestOptions.data}');
      } else {
        DLoggerHelper.error('[DEBUG] Lỗi không xác định: $e');
      }
    }

  }
}
