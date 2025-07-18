import 'dart:math';

import 'package:app_my_app/data/repositories/product/product_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:app_my_app/data/repositories/vouchers/ClaimedVoucherRepository.dart';
import 'package:app_my_app/data/repositories/vouchers/VoucherRepository.dart';
import 'package:app_my_app/features/shop/controllers/product/order_controller.dart';
import 'package:app_my_app/features/voucher/models/VoucherModel.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/formatter/formatter.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loader.dart';
import '../../personalization/controllers/user_controller.dart';
import '../../shop/controllers/product/cart_controller.dart';
import '../../shop/models/product_model.dart';
import '../models/UserClaimedVoucher.dart';
import '../models/VoucherAppliedInfo.dart';

class VoucherController extends GetxController{
  static VoucherController get  instance => Get.find();
  final voucherRepository = VoucherRepository.instance;
  final claimedVoucherRepository = ClaimedVoucherRepository.instance;
  final productRepository = ProductRepository.instance;
  var allClaimedVouchers = <String>[].obs;
  var allClaimedVoucherModel = <VoucherModel>[].obs;// toan bo nhung voucher da nhan(ca dung va chua dung)
  var claimedVouchers = <String>[].obs; // nhan ma chua dung
  var appliedVouchers = <String>[].obs;
  var appliedVouchersInfo = <VoucherAppliedInfo>[].obs;
  var expandedVouchers = <VoucherAppliedInfo>[].obs;
  var allVouchers = <VoucherModel>[].obs;
  late AppLocalizations lang;
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }
  Future<List<VoucherModel>> getAllVouchers() async {
    try {
      final vouchers = await voucherRepository.fetchAllVouchers();
      return vouchers;
    } catch (e) {
      TLoader.errorSnackbar(title: 'getAllVouchers() not found', message: e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
  }

  Future<List<VoucherModel>> getFreeShippingVouchers() async {
    try {
      final vouchers = await voucherRepository.fetchFreeShippingVouchers();
      return vouchers;
    } catch (e) {
      TLoader.errorSnackbar(title: 'getFreeShippingVouchers() not found', message: e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
  }

  Future<List<VoucherModel>> getEntirePlatformVouchers() async {
    try {
      final vouchers = await voucherRepository.fetchEntirePlatformVouchers();
      return vouchers;
    } catch (e) {
      TLoader.errorSnackbar(title: 'getEntirePlatformVouchers() not found', message: e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
  }

  Future<List<VoucherModel>> getExpiredVouchers() async {
    try {
      final vouchers = await voucherRepository.fetchExpiredVouchers();
      return vouchers;
    } catch (e) {
      TLoader.errorSnackbar(title: 'getExpiredVouchers() not found', message: e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
  }

  Future<List<VoucherModel>> getUserClaimedVoucher(String userId) async {
    try {
      final vouchers = await voucherRepository.fetchUserClaimedVouchersDuplicated(userId);
      return vouchers;
    } catch (e) {
      TLoader.errorSnackbar(title: 'getUserClaimedVoucher() not found', message: e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
  }

  Future<List<VoucherModel>> getUsedVoucher(String userId) async {
    try {
      final vouchers = await voucherRepository.fetchUsedVoucher(userId);
      return vouchers;
    } catch (e) {
      TLoader.errorSnackbar(title: 'getUserClaimedVoucher() not found', message: e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
      return [];
    }
  }
  Future<bool> isUsed(String userId, String voucherId) async {
    return await claimedVoucherRepository.isUsed(userId, voucherId);
  }

  Future<List<VoucherModel>> getApplicableVouchers() async {
    final startTime = DateTime.now();
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      // Danh sách voucher thỏa mãn
      List<VoucherModel> applicableVouchers = [];
      List<VoucherModel> vouchers = await getUserClaimedVoucher(userId);
      // Lấy tất cả productId từ cart 1 lần
      final cartItems = CartController.instance.cartItems;
      final cartProductIds = cartItems.map((item) => item.productId).toList();

// Lấy toàn bộ productModels trong 1 lần gọi song song
      final productModels = await Future.wait(cartProductIds.map((id) => productRepository.getProductById(id)));

// Ghép lại với cart item để truy cập nhanh
      final cartProducts = <String, ProductModel>{};
      for (int i = 0; i < cartItems.length; i++) {
        cartProducts[cartItems[i].productId] = productModels[i]!;
      }

      for (var voucher in vouchers) {
        print("Tên voucher gợi ý áp dụng: ${voucher.title} -type: ${voucher.type} \n");
        // Kiểm tra từng loại voucher
        switch (voucher.type) {
          case 'free_shipping':
          // Kiểm tra điều kiện minimumOrder có khác null và tổng đơn hàng có đủ không
            if ((voucher.minimumOrder ?? double.infinity) <= OrderController.instance.totalAmount.value &&OrderController.instance.fee.value!=0 ) {
              applicableVouchers.add(voucher);
            }
            break;

          case 'fixed_discount':
            applicableVouchers.add(voucher);
            break;

          case 'percentage_discount':
            applicableVouchers.add(voucher);
            break;

          case 'category_discount':
            bool isApplicable = false;
            // Nếu voucher.applicableCategories là null thì coi như không có danh mục áp dụng (bỏ qua)
            if (voucher.applicableCategories != null) {
              for (var product in CartController.instance.cartItems) {
                if (voucher.applicableCategories!.contains(product.category)) {
                  isApplicable = true;
                  break;
                }
              }
            }
            if (isApplicable) {
              applicableVouchers.add(voucher);
            }
            break;

          case 'product_discount':
            bool isApplicable = false;
            // Nếu voucher.applicableProducts là null thì coi như không có sản phẩm áp dụng (bỏ qua)
            if (kDebugMode) {
              print("applicableProducts: ${voucher.applicableProducts}");
            }

            if (voucher.applicableProducts != null) {
              for (var product in CartController.instance.cartItems) {
                if (kDebugMode) {
                  print("product.title: ${product.title}");
                }
                if (voucher.applicableProducts!.any((applicableTitle) =>
                applicableTitle.toLowerCase().trim() ==
                    product.title.toLowerCase().trim())) {
                  isApplicable = true;
                  break;
                }
              }
            }
            if (kDebugMode) {
              print("product_discount: isApplicable: $isApplicable");
            }
            if (isApplicable) {
              applicableVouchers.add(voucher);
            }
            break;

          case 'user_discount':
          // Sử dụng toán tử null-aware để kiểm tra danh sách người dùng áp dụng
            if (voucher.applicableUsers?.contains(userId) ?? false) {
              applicableVouchers.add(voucher);
            }
            break;

          case 'first_purchase':   applicableVouchers.add(voucher);
            break;

          case 'campaign_discount':
            if (isCampaignActive(voucher)) {
              applicableVouchers.add(voucher);
            }
            break;

          case 'points_based':
            final userPoints = UserController.instance.user.value.points;
            // Nếu requiredPoints khác null và người dùng có đủ điểm
            if ((voucher.requiredPoints ?? double.infinity) <= userPoints) {
              applicableVouchers.add(voucher);
            }
            break;

          case 'limited_quantity':
          // Kiểm tra quantity có khác null và lớn hơn 0
            if ((voucher.quantity) > 0) {
              applicableVouchers.add(voucher);
            }
            break;

          case 'minimum_order':
            if ((voucher.minimumOrder ?? double.infinity) <= OrderController.instance.totalAmount.value) {
              applicableVouchers.add(voucher);
            }
            break;

          case 'cashback':
            break;

          case 'flat_price':
            bool isApplicable = false;
            if (voucher.applicableCategories != null) {
              for (var product in CartController.instance.cartItems) {
                if (voucher.applicableCategories!.contains(product.category)) {
                  isApplicable = true;
                  break;
                }
              }
            }
            if (isApplicable) {
              applicableVouchers.add(voucher);
            }
            break;

          case 'group_voucher':
           final isAvailable = await isGroupVoucherAvailable(voucher,cartProducts);
           print("Group voucher co avai k: $isAvailable");
           if(isAvailable){
             applicableVouchers.add(voucher);
           }
            break;

          case 'time_based':
            if (isTimeInRange(voucher.startDate, voucher.endDate)) {
              applicableVouchers.add(voucher);
            }
            break;

          default:
            break;
        }
      }
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("🔥 Thời gian suggest cac voucher goi y: ${duration.inMilliseconds}ms");
      return applicableVouchers;
    } catch (e) {
      throw 'Error checking applicable vouchers: $e';
    }
  }

  bool isCampaignActive(VoucherModel voucher) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(voucher.startDate.toDate()) &&
        currentDate.isBefore(voucher.endDate.toDate());
  }

  bool isTimeInRange(Timestamp? startDate, Timestamp? endDate) {
    final currentDate = DateTime.now();
    return startDate != null &&
        endDate != null &&
        currentDate.isAfter(startDate.toDate()) &&
        currentDate.isBefore(endDate.toDate());
  }

  Future<void> initializeClaimedVouchers(String userId) async {
    try{
      final vouchers = await claimedVoucherRepository.fetchUserClaimedVouchers(userId);
      final allVouchers = await claimedVoucherRepository.fetchAllClaimedVouchers(userId);
      final ids = vouchers.map((voucher)=> voucher.voucherId).toList();
      final allIds = allVouchers.map((voucher)=> voucher.voucherId).toList();
      claimedVouchers.assignAll(ids);
      allClaimedVouchers.assignAll(allIds);
      allClaimedVoucherModel.assignAll(allVouchers as Iterable<VoucherModel>);
    }catch (e){
      print("Loi initializeClaimedVouchers: $e ");
    }
  }

  Future<void> initializeUsedVouchers(String userId) async {
    try{
      final vouchers = await claimedVoucherRepository.fetchUserUsedVouchers(userId);
      final ids = vouchers.map((voucher)=> voucher.voucherId).toList();
      appliedVouchers.assignAll(ids);
    }catch (e){
      TLoader.errorSnackbar(
        title: 'Error',
        message: 'Failed to initialize used vouchers: $e',
      );
    }
  }



  @override
  Future<void> onInit() async {
    super.onInit();
    // Gọi hàm khởi tạo giá trị claimedVouchers
    final userId = AuthenticationRepository.instance.authUser!.uid;
    allVouchers.value  = await voucherRepository.fetchAllVouchers();// Cập nhật giá trị userId phù hợp
    await initializeClaimedVouchers(userId);
    await  initializeUsedVouchers(userId);
  }

  // Hàm để nhận voucher
  Future<void> claimVoucher(String voucherId,String userId) async {
    final claimedVoucher = ClaimedVoucherModel(
      voucherId: voucherId,
      claimedAt: Timestamp.now(),
      isUsed: false,
    );
    final voucher = await voucherRepository.getVoucherById(voucherId);
    allClaimedVoucherModel.add(voucher!);
    try {
      final isAlreadyClaimed = await claimedVoucherRepository.isClaimed(userId, voucherId);
      if(isAlreadyClaimed){
        if(!claimedVouchers.contains(voucherId)){
          claimedVouchers.add(voucherId);
        }
      }else{
        claimedVouchers.add(voucherId);

        TLoader.successSnackbar(title: lang.translate('voucher_claimed_success'));
        await claimedVoucherRepository.claimVoucher(userId, claimedVoucher);
        final voucher = await voucherRepository.getVoucherById(voucherId);
        if(voucher!=null){
          final updatedVoucher = voucher.copyWith(
            remainingQuantity: voucher.remainingQuantity - 1,
            claimedUsers: (voucher.claimedUsers ?? [])..add(userId),
          );
          await voucherRepository.updateVoucher(voucherId, updatedVoucher.toJson());
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error claiming voucher: $e');
      }
    }
  }
  //Ham xu ly ap dung 1 voucher
  Future<num> applyVoucher(String voucherId, String userId) async {
    final startTime = DateTime.now();
    try {
      if (kDebugMode) {
        print("=== Bắt đầu áp dụng voucher ===");
        print("Voucher ID: $voucherId, User ID: $userId");
      }

      bool isUsed = await claimedVoucherRepository.isUsed(userId, voucherId);
      if (kDebugMode) {
        print("Voucher đã được sử dụng? $isUsed");
      }

      if (isUsed) {
        if (!appliedVouchers.contains(voucherId)) {
          appliedVouchers.add(voucherId);
          if (kDebugMode) {
            print("Voucher $voucherId đã sử dụng trước đó nhưng chưa có trong appliedVouchers. Đã thêm vào list.");
          }
        } else {
          if (kDebugMode) {
            print("Voucher $voucherId đã có trong appliedVouchers, không thực hiện gì thêm.");
          }
        }
        return 0;
      } else {
        if(OrderController.instance.netAmount.value==0){
          TLoader.warningSnackbar(title: lang.translate('no_apply_voucher_msg'));
          return 0;
        }
        else{
          final voucher = await voucherRepository.getVoucherById(voucherId);
          if(voucher != null){
          final discount =    await applyVoucherDiscount(voucher,voucherId,userId);
          return discount;
          }
        }
      }
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("🔥 Thời gian apply voucher: ${duration.inMilliseconds}ms");
    } catch (e) {
     if (kDebugMode) {
       print("Loi: ${e.toString()}");
     }
     return 0;
    }
    return 0;
  }

  Future<num> applyVoucherDiscount(VoucherModel voucher,String voucherId, String userId ) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TFullScreenLoader.openLoadingDialog('Calculate voucher now...', TImages.loaderAnimation);
    });
    try{
      num discountValue = 0.0;
      if (kDebugMode) {
        print("=== Bắt đầu tính toán discount cho voucher ===");
        print("Voucher type: ${voucher.type}");
        print("Total Discount ban đầu: ${OrderController.instance.totalDiscount.value}");
      }

      switch(voucher.type){
        case 'fixed_discount':
          discountValue = voucher.discountValue;
          appliedVouchersInfo.add(
            VoucherAppliedInfo(
              type: voucher.type,
              discountValue: voucher.discountValue,
            ),
          );
          if (kDebugMode) {
            print("Fixed discount: $discountValue");
          }
          break;
        case 'percentage_discount':
          final calculatedDiscount = OrderController.instance.totalAmount.value * (voucher.discountValue / 100);
          discountValue = min(calculatedDiscount, voucher.maxDiscount!);
          appliedVouchersInfo.add(
            VoucherAppliedInfo(
              type: voucher.type,
              discountValue: discountValue,
            ),
          );
          break;
        case 'free_shipping':
          if(OrderController.instance.totalAmount.value>=voucher.minimumOrder! && OrderController.instance.fee.value!=0 ){
            discountValue = OrderController.instance.fee.value;
            appliedVouchersInfo.add(
              VoucherAppliedInfo(
                type: voucher.type,
                discountValue: discountValue,
              ),
            );
            OrderController.instance.fee.value = 0;
          }
          else {
            TLoader.warningSnackbar(title: lang.translate('no_apply_freeship'));
          }
          break;
        case 'limited_quantity':
          discountValue = OrderController.instance.totalAmount.value * (voucher.discountValue/100);
          appliedVouchersInfo.add(
            VoucherAppliedInfo(
              type: voucher.type,
              discountValue: discountValue,
            ),
          );
          break;
        case 'category_discount':
        // Cần kiểm tra sản phẩm có thuộc danh mục không, giả sử có danh sách sản phẩm trong giỏ hàng
          discountValue = calculateCategoryDiscount(voucher);
          if (kDebugMode) {
            print("Category discount: $discountValue");
          }
          break;

        case 'product_discount':
        // Cần kiểm tra sản phẩm có nằm trong danh sách áp dụng không
          discountValue = calculateProductDiscount(voucher);
          if (kDebugMode) {
            print("Product discount: $discountValue");
          }
          break;

        case 'first_purchase':
          discountValue = await applyFirstPurchaseVoucher(voucher);
          if(discountValue==0){
            TLoader.warningSnackbar(title: lang.translate('no_apply_mininum_value_voucher'));
          }
          if (kDebugMode) {
            print("First purchase discount: $discountValue");
          }
          break;

        case 'campaign_discount':
          discountValue = OrderController.instance.totalAmount.value * (voucher.discountValue/100);
          appliedVouchersInfo.add(
            VoucherAppliedInfo(
              type: voucher.type,
              discountValue: discountValue,
            ),
          );
          break;

        case 'points_based':
          discountValue = await applyPointsBasedVoucher(voucher);
          break;
        case 'minimum_order':
          if (OrderController.instance.totalAmount.value >= voucher.minimumOrder!) {
            discountValue = voucher.discountValue;
            appliedVouchersInfo.add(
              VoucherAppliedInfo(
                type: voucher.type,
                discountValue: discountValue,
              ),
            );
            if (kDebugMode) {
              print("Minimum order discount: $discountValue");
            }
          } else {
            if (kDebugMode) {
              print("Minimum order: Tổng đơn hàng chưa đạt yêu cầu (${OrderController.instance.totalAmount.value} < ${voucher.minimumOrder})");
            }
          }
          break;
        case 'cashback':
        // applyCashback(voucher);
          break;

        case 'flat_price':
          discountValue = calculateFlatPriceDiscount(voucher);
          if(discountValue==0){
            TLoader.warningSnackbar(title: lang.translate('no_apply_mininum_value_voucher'));
          }
          if (kDebugMode) {
            print("Flat price discount: $discountValue");
          }
          break;
        case 'user_discount':
          discountValue = OrderController.instance.totalAmount.value * (voucher.discountValue/100);
          appliedVouchersInfo.add(
            VoucherAppliedInfo(
              type: voucher.type,
              discountValue: discountValue,
            ),
          );
          if (kDebugMode) {
            print("user_discount: $discountValue");
          }
          break;

        case 'group_voucher':
          discountValue  = await calculateGroupVoucherDiscount(voucher);
          break;
        case 'time_based':
          if (isTimeInRange(voucher.startDate, voucher.endDate)) {
            if (kDebugMode) {
              print("totalAmount: ${OrderController.instance.totalAmount.value}");
              print("discountValue: ${voucher.discountValue}");
            }
            discountValue = OrderController.instance.totalAmount.value * (voucher.discountValue / 100);
            appliedVouchersInfo.add(
              VoucherAppliedInfo(
                type: voucher.type,
                discountValue: discountValue,
              ),
            );
            if (kDebugMode) {
              print("Time-based discount: $discountValue");
            }
          } else {
            if (kDebugMode) {
              print("Time-based voucher: Không nằm trong khoảng thời gian áp dụng.");
            }
          }
          break;
        default:
          if (kDebugMode) {
            print("Voucher type '${voucher.type}' không được xử lý.");
          }
          break;
      }
      // Cập nhật giá trị netAmount nếu có giảm giá
      if (discountValue > 0) {
        OrderController.instance.totalDiscount.value += discountValue;
        if (kDebugMode) {
          print("Updated Total Discount: ${OrderController.instance.totalDiscount.value}");
          print("Total Amount: ${OrderController.instance.totalAmount.value}");
        }
        OrderController.instance.netAmount.value =
            (OrderController.instance.totalAmount.value - OrderController.instance.totalDiscount.value).clamp(0, double.infinity);
        if (kDebugMode) {
          print("Updated Net Amount: ${OrderController.instance.netAmount.value}");
        }
        appliedVouchers.add(voucherId);
        TLoader.successSnackbar(title: lang.translate('voucher_used_success'));
        await claimedVoucherRepository.applyVoucher(userId, voucherId);
      }else {
        if (kDebugMode) {
          print("Không có discount nào được áp dụng từ voucher.");
        }
      }
      return discountValue;
    }catch(e){
      print('Error in applyVoucherDiscount(): $e');
    }finally{
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TFullScreenLoader.stopLoading();
      });
    }
    return 0;
  }

  double calculateProductDiscount(VoucherModel voucher) {
    double discount = 0;
    List<String> details = [];
    for (var product in CartController.instance.cartItems) {
      if (voucher.applicableProducts!.contains(product.title)) {
       double productDiscount = product.price * (voucher.discountValue / 100)*product.quantity;
        discount += productDiscount;
        final info = '${product.title} - ${product.price} x ${product.quantity} = -${productDiscount.toStringAsFixed(2)}';
        details.add(info);
        if (kDebugMode) {
          print("Tên sản phẩm có ProductDiscount: ${product.title} \n giá trị discount là: ${product.price * (voucher.discountValue / 100)*product.quantity}");
        }
      }
    }
    appliedVouchersInfo.add(VoucherAppliedInfo(
        type: voucher.type,
        discountValue: discount,
        appliedDetails: details.isNotEmpty? details :null
    ));
    return discount;
  }

  double calculateCategoryDiscount(VoucherModel voucher) {
    // Giả sử có danh sách sản phẩm trong giỏ hàng
    double discount = 0;
    List<String> details = [];
    for (var product in CartController.instance.cartItems) {
      if (voucher.applicableCategories!.contains(product.category)) {
        double productDiscount = product.price * (voucher.discountValue / 100)*product.quantity;
        discount += productDiscount;
        final info = '${product.title} - ${product.price} x ${product.quantity} = -${productDiscount.toStringAsFixed(2)}';
        details.add(info);
      }
    }
    appliedVouchersInfo.add(VoucherAppliedInfo(
        type: voucher.type,
        discountValue: discount,
        appliedDetails: details.isNotEmpty? details :null
    ));
    return discount;
  }

  Future<double> calculateGroupVoucherDiscount(VoucherModel voucher) async {
    double discount = 0;
    List<String> details = [];

    for (var item in CartController.instance.cartItems) {
      bool isApplicable = false;
      final product = await productRepository.getProductById(item.productId);
      if (voucher.brandId != null && product?.brand?.id == voucher.brandId) {
        isApplicable = true;
      } else if (voucher.shopId != null && product?.shop.id == voucher.shopId) {
        isApplicable = true;
      } else if (voucher.categoryId != null &&
          product?.categories != null &&
          product!.categories!.any((category) => category.id == voucher.categoryId)) {
        isApplicable = true;
      }

      if (isApplicable) {
        final double productDiscount = item.price * (voucher.discountValue / 100) * item.quantity;
        discount += productDiscount;
        final info = '${product?.title} - ${product?.price} x ${item.quantity} = Giảm: ${DFormatter.formattedAmount(productDiscount)} VND';
        details.add(info);
        print('✅ Áp dụng: ${product?.title} - Giá: ${item.price} - Số lượng: ${item.quantity} - Giảm: ${productDiscount.toStringAsFixed(2)}');
      } else {
        print('❌ Không áp dụng: ${product?.title} - Brand: ${product?.brand?.id}, Shop: ${product?.shop.id}, Categories: ${product?.categories?.map((c) => c.id).join(',')}');
      }
    }
    if(details.isNotEmpty && discount>0){
      appliedVouchersInfo.add(VoucherAppliedInfo(
          type: voucher.type,
          discountValue: discount,
          appliedDetails: details.isNotEmpty? details :null
      ));
    }else{
      TLoader.warningSnackbar(title: "Không có sản phẩm nào trong giỏ hàng đủ điều kiện áp dụng group voucher.Hãy chọn sản phẩm thuộc phạm vi voucher group đc giảm giá");
    }

    return discount;
  }

  Future<bool> isGroupVoucherAvailable(VoucherModel voucher, Map<String, ProductModel> cartProducts) async {
    for (var entry in cartProducts.entries) {
      final product = entry.value;

      if ((voucher.brandId != null && product.brand?.id == voucher.brandId) ||
          (voucher.shopId != null && product.shop.id == voucher.shopId) ||
          (voucher.categoryId != null &&
              product.categories != null &&
              product.categories!.any((category) => category.id == voucher.categoryId))) {
        return true;
      }
    }
    return false;
  }



  double calculateFlatPriceDiscount(VoucherModel voucher) {
    double applicableTotal = 0.0;
    List<String> details = [];
    for (var product in CartController.instance.cartItems) {
      if (voucher.applicableCategories!.contains(product.category)) {
        final double productDiscount = product.price*product.quantity;
        applicableTotal += productDiscount;
        final info = '${product.title} - ${product.price} x ${product.quantity} = -${productDiscount.toStringAsFixed(2)}';
        details.add(info);
      }
    }
    if (kDebugMode) {
      print("applicableTotal: ${applicableTotal}");
      print("discountValue: ${voucher.discountValue}");
    }
    // Nếu tổng giá của sản phẩm vượt quá flatPrice, giảm giá chính là phần chênh lệch
    if (applicableTotal > voucher.discountValue) {
      appliedVouchersInfo.add(VoucherAppliedInfo(
          type: voucher.type,
          discountValue: voucher.discountValue,
          appliedDetails: details.isNotEmpty? details :null
      ));
      return  voucher.discountValue.toDouble();
    }

    return 0.0;
  }

  Future<num> applyFirstPurchaseVoucher(VoucherModel voucher) async {
    // Nếu collection Orders rỗng (chưa có đơn hàng nào)
    if (await voucherRepository.isFirstPurchaseVoucher(voucher)) {
      appliedVouchersInfo.add(
        VoucherAppliedInfo(
          type: voucher.type,
          discountValue: voucher.discountValue,
        ),
      );
      return voucher.discountValue;
    } else {
      TLoader.warningSnackbar(title: lang.translate('no_apply_first_purchase_voucher'));
      return 0;
    }
  }

  Future<num> applyPointsBasedVoucher(VoucherModel voucher) async {
    final userPoints = UserController.instance.user.value.points; // Điểm hiện có của người dùng
    if (userPoints >= voucher.requiredPoints! ) {
      // Tính điểm sau khi sử dụng voucher
      num newPoints = userPoints - voucher.requiredPoints!;
      // Cập nhật lại số điểm của người dùng
      UserRepository.instance.updateUserPoints(UserController.instance.user.value.id, newPoints);
      appliedVouchersInfo.add(
        VoucherAppliedInfo(
          type: voucher.type,
          discountValue: voucher.discountValue,
        ),
      );
      return voucher.discountValue;
    } else {
      TLoader.warningSnackbar(title: lang.translate('no_apply_points-based_voucher'));
      return 0;
    }
  }
}
