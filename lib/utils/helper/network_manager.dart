import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:lcd_ecommerce_app/utils/popups/loader.dart';

/// Quản lý trạng thái kết nối mạng và cung cấp các phương thức để kiểm tra và xử lý các thay đổi về kết nối.
class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Rx<List<ConnectivityResult>> _connectionStatus = Rx<List<ConnectivityResult>>([]);


  /// Khởi tạo trình quản lý mạng và thiết lập luồng để liên tục kiểm tra trạng thái kết nối.
  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus ) ;
  }

  // Cập nhật trạng thái kết nối dựa trên các thay đổi về kết nối và hiển thị popup thông báo khi không có internet.
  void _updateConnectionStatus(List<ConnectivityResult> result) async {
    _connectionStatus.value = result;
    if (_connectionStatus.value == List<ConnectivityResult>) {
      TLoader.warningSnackbar(title: 'No interner connection');
    }
  }

  /// Kiểm tra trạng thái kết nối internet.
  /// Trả về `true` nếu được kết nối, `false` nếu không.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Hủy hoặc đóng luồng kết nối đang hoạt động.
  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}
