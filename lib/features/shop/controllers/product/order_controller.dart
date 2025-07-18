import 'package:app_my_app/features/bonus_point/handlers/mission_tracker.dart';
import 'package:app_my_app/utils/enum/enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:app_my_app/common/widgets/success_screen/success_screen.dart';
import 'package:app_my_app/data/repositories/order/order_repository.dart';
import 'package:app_my_app/features/personalization/controllers/address_controller.dart';
import 'package:app_my_app/features/personalization/controllers/user_controller.dart';
import 'package:app_my_app/features/shop/controllers/product/cart_controller.dart';
import 'package:app_my_app/features/shop/controllers/product/checkout_controller.dart';
import 'package:app_my_app/features/voucher/models/VoucherAppliedInfo.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import 'package:app_my_app/navigation_menu.dart';
import 'package:app_my_app/utils/constants/enums.dart';
import 'package:app_my_app/utils/constants/image_strings.dart';
import 'package:app_my_app/utils/popups/full_screen_loader.dart';
import 'package:app_my_app/utils/popups/loader.dart';

import '../../../../api/ApiService.dart';
import '../../../../data/model/OrderDetailResponseModel.dart';
import '../../../../data/model/OrderResponseModel.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/formatter/formatter.dart';
import '../../../../utils/helper/cloud_helper_functions.dart';
import '../../../notification/controller/notification_service.dart';
import '../../../payment/services/stripe_service.dart';
import '../../../personalization/models/address_model.dart';
import '../../../suggestion/suggestion_repository.dart';
import '../../models/order_model.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();
  var fee = 0.0.obs; // Biến quan sát được để lưu giá trị Fee
  var totalAmount = 0.0.obs; // Biến quan sát được để lưu giá trị totalFee
  var netAmount = 0.0.obs;
  var totalDiscount = 0.0.obs;
  late AppLocalizations lang;
  final cartController = Get.put(CartController());
  final addressController = AddressController.instance;
  final checkoutController = CheckoutController.instance;
  final userController = UserController.instance;
  final orderRepository = Get.put(OrderRepository());
  final suggestionRepository = Get.put(ProductSuggestionRepository());
  ShippingOrderModel? shippingOrder;
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }
  @override
  void onInit() {
    super.onInit();
    // Lắng nghe thay đổi địa chỉ để tự động tính lại phí
    ever(addressController.selectedAddress, (_) {
      final subTotal = CartController.instance.totalCartPrice.value;
      if (subTotal > 0) {
        calculateFeeAndTotal(subTotal);
      }
    });
  }

  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userOrders = await orderRepository.fetchUserOrders();
      await suggestionRepository.generateAndSaveSuggestions(userOrders);
      return userOrders;
    } catch (e) {
      TLoader.warningSnackbar(title: lang.translate('snap'), message: e.toString());
      return [];
    }
  }

  // Hàm tính phí và tổng phí
  Future<void> calculateFeeAndTotal(double subTotal) async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      if (userId.isEmpty) return;
      // Fetch current user details
      final userDetails = await userController.fetchCurrentUserDetails(userId);
      final selectedAddress = addressController.selectedAddress.value;
      if (selectedAddress == AddressModel.empty()) {
        TLoader.errorSnackbar(title: lang.translate('error'), message: lang.translate('no_address_selected'));
        return;
      }

      final items = cartController.cartItems.map((item) {
        return {
          "name": item.title,
          "code": item.productId,
          "quantity": item.quantity,
          "price": item.price.toInt(),
          "length": 100,
          "width": 100,
          "weight": 5000,
          "height": 100,// Thêm giá trị mặc định hoặc tính toán từ sản phẩm
          "category": {"level1": "Áo"}
        };
      }).toList();
      final shippingData = {
        "payment_type_id": 2,
        "service_type_id": 2,
        "note": "Order note here",
        "required_note": "CHOXEMHANGKHONGTHU",
        "from_name": "TinTest124",
        "from_phone": "0987654321",
        "from_address": "72 Thành Thái, Phường 14, Quận 10, Hồ Chí Minh, Vietnam",
        "from_ward_name": "Phường 14",
        "from_district_name": "Quận 10",
        "from_province_name": "HCM",
        "to_name": "${userDetails.firstName} ${userDetails.lastName}",
        "to_phone": selectedAddress.phoneNumber,
        "to_address": selectedAddress.toString(),
        "to_ward_name": selectedAddress.commune,
        "to_district_name": selectedAddress.district,
        "to_province_name": selectedAddress.city,
        "weight": 1200,
        "cod_amount": 15000,
        "content": "Đơn hàng thời trang",
        "items": items
      };

      final shippingService = ShippingOrderService();
      final response = await shippingService.createShippingOrder(shippingData);
      shippingOrder = ShippingOrderModel.fromJson(response);
      if(shippingOrder!=null){
        fee.value = shippingOrder!.totalFee.toDouble();//doi sang USD
      }
      totalAmount.value = subTotal + fee.value;
      netAmount.value = totalAmount.value;
    } catch (e) {
      TLoader.errorSnackbar(title: lang.translate('snap'), message: e.toString());
    }
  }

  //add methods for order processing
  Future<void > processOrder(double subTotal,BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TFullScreenLoader.openLoadingDialog(
          lang.translate('process_order'), TImages.pencilAnimation);
    });
    try {
      ShippingOrderService shippingService  =  ShippingOrderService();
      final userId = AuthenticationRepository.instance.authUser!.uid;
      final orderCode = shippingOrder!.orderCode;
      // 👉 Gọi makePayment trước để UI phản hồi nhanh
      final result =  await StripeService.instance.makePayment(
        netAmount.value / 24500,
        "usd",
        userId,
        orderCode,
        context,
      );
      if (!result) {
        throw Exception("Payment failed or cancelled.");
      }
      try {
        if (kDebugMode) {
          final detailOrder = await shippingService.getOrderDetail(shippingOrder!.orderCode);
          final shippingDetailOrder = OrderDetailModel.fromJson(detailOrder);
          DateTime deliveryTime = DateTime.parse(shippingOrder!.expectedDeliveryTime).toLocal();
          final userId = AuthenticationRepository.instance.authUser!.uid;
          final order = OrderModel(
              id: shippingOrder!.orderCode,
              userId: userId,
              status: OrderStatus.pending,
              totalAmount: totalAmount.value,
              orderDate: DateTime.now(),
              paymentMethod: checkoutController.selectedPaymentMethod.value.name,
              address: addressController.selectedAddress.value,
              deliveryDate: deliveryTime,
              items: cartController.cartItems.toList(),
              orderDetail: shippingDetailOrder);
          await orderRepository.saveOrder(order, userId);
          cartController.clearCart();
          await MissionTracker.instance.track(MissionType.quickOrder, context);
          await MissionTracker.instance.track(
            MissionType.highValueOrder,
            context,
            extraData: netAmount.value, // Giá trị đơn hàng
          );
          // Gửi thông báo
          final formattedTime = DFormatter.FormattedDate(DateTime.now());
          String url = await TCloudHelperFunctions.uploadAssetImage(
              "assets/images/content/order_success.png",
              "order_success"
          );

          await NotificationService.instance.createAndSendNotification(
            title: lang.translate('order_success'),
            message: "${lang.translate('order_success_msg')} $formattedTime",
            type: "order",
            orderId: orderCode,
            imageUrl: url,
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          TFullScreenLoader.stopLoading();
        });

        // ✅ Sau khi tất cả xử lý xong thì mới điều hướng
      } catch (e) {
        if (kDebugMode) {
          print('Failed to create order: $e');
        }
      }

    } catch (e) {
      TLoader.errorSnackbar(title: lang.translate('snap'), message: e.toString());
    }
  }

}
