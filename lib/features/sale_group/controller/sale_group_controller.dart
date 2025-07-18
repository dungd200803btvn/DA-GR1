import 'package:app_my_app/data/repositories/brands/brand_repository.dart';
import 'package:app_my_app/data/repositories/categories/category_repository.dart';
import 'package:app_my_app/features/shop/models/category_model.dart';
import 'package:app_my_app/utils/formatter/formatter.dart';
import 'package:app_my_app/utils/popups/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/sale_group/sale_group_repository.dart';
import '../../../data/repositories/shop/shop_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/enum/enum.dart';
import '../../../utils/helper/cloud_helper_functions.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../notification/controller/notification_service.dart';
import '../../shop/models/brand_model.dart';
import '../../shop/models/shop_model.dart';
import '../model/sale_group_model.dart';

class SaleGroupController extends GetxController {
  static SaleGroupController get instance => Get.find();
  final SaleGroupRepository repository = SaleGroupRepository.instance;
  final ShopRepository shopRepository = ShopRepository.instance;
  final BrandRepository brandRepository = BrandRepository.instance;
  final CategoryRepository categoryRepository = CategoryRepository.instance;
  final UserRepository userRepository = UserRepository.instance;
  List<ShopModel> topShops = [];
  List<CategoryModel> topCategories = [];
  List<BrandModel> topBrands = [];
  RxList<SaleGroupModel> groups = <SaleGroupModel>[].obs;
  RxBool isLoading1 = false.obs;
  bool isLoading = false;
  String? errorMessage;
  late AppLocalizations lang;
  String? selectedType; // "shop", "brand", "category"
  String? selectedId;
  String? selectedName; // mã của đối tượng được chọn (shop/brand/category)
  int? selectedTargetParticipants;
  DateTime? expiresAt;
  final TextEditingController groupNameController = TextEditingController();
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
    fetchSaleGroups();
    super.onInit();
  }

  Future<void> fetchSaleGroups() async{
    try{
      isLoading1.value = true;
      final group = await repository.getSaleGroupsByCreator();
      group.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      groups.assignAll(group);
    }catch(e){
      print('Error in fetchSaleGroups(): $e');
    }finally{
      isLoading1.value = false;
    }
  }

  Future<void> createSaleGroup(SaleGroupModel group) async {
    isLoading1.value = true;
    errorMessage = null;
    try {
      await repository.createSaleGroup(group);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading1.value = false;
    }
  }

  Future<void> loadTopObjects(String selectedType) async {
    try {
      if (selectedType == "shop") {
        topShops = await shopRepository.fetchTopShops();
      }
      else if (selectedType == "brand") {
        topBrands = await brandRepository.fetchTopBrands();
      }
      else if (selectedType == "category") {
        topCategories = await categoryRepository.fetchTopCategories();
      }
    } catch (e) {
      // xử lý lỗi nếu cần
      print(e);
    }
  }

  Future<void> updateGroupStatus(String groupId, String newStatus) async{
    try {
      await repository.updateGroupStatus(groupId, newStatus);
      await fetchSaleGroups();
    } catch (e) {
      debugPrint("❌ Failed to update group status: $e");
    }
  }
  Future<void> sendNotificationWhenGroupExpired(SaleGroupModel group) async{
    final String expiredMessage =
        "Nhóm ${group.name} chưa đủ thành viên và đã hết thời gian chờ nên status chuyển thành expired";
    final String expiredImageUrl =
    await TCloudHelperFunctions.uploadAssetImage(
        "assets/images/content/time_expired.jpg", "time_expired");
    for (final userId in group.participants) {
      try {
        final user = await userRepository.getUserById(userId);
        await NotificationService.instance
            .sendNotificationToDeviceToken(
          deviceToken: user.fcmToken,
          title: "Đã hết thời gian rủ bạn bè săn sale!",
          message: expiredMessage,
          type: 'group_expired',
          imageUrl: expiredImageUrl,
          friendId: userId,
        );
      } catch (e) {
        print("Lỗi gửi thông báo đến user $userId: $e");
      }
    }
  }

  void resetData() {
    topShops = [];
    topCategories = [];
    topBrands = [];
    isLoading1.value = false;
    errorMessage = null;
    selectedType = null;
    selectedId = null;
    selectedName = null;
    selectedTargetParticipants = null;
    expiresAt = null;
    update();
    // Cập nhật UI nếu cần thiết
  }

  Future<SaleGroupModel?> onClickCreate(BuildContext context, double discount) async {
    TFullScreenLoader.openLoadingDialog(
        'Handle request now...', TImages.loaderAnimation);
    try {
      // Giả sử lấy user id hiện tại từ hệ thống auth
      String currentUserId = AuthenticationRepository.instance.authUser!.uid;
      final newGroup = SaleGroupModel(
        id: '',
        name: groupNameController.text,
        shopId: selectedType == "shop" ? selectedId : null,
        brandId: selectedType == "brand" ? selectedId : null,
        categoryId: selectedType == "category" ? selectedId : null,
        targetParticipants: selectedTargetParticipants!,
        currentParticipants: 1,
        discount: discount,
        participants: [currentUserId],
        creatorId: currentUserId,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now(),
        status: SaleGroupStatus.pending,
        selectedObjectName: selectedName?? ""
      );
      await  createSaleGroup(newGroup);
      String date =   DFormatter.FormattedDate(DateTime.now().add(const Duration(hours: 24)));
      String baseMessage = lang.translate(
        'create_group_success_message',
        args: [
          selectedType.toString(),
          selectedType.toString(),
          selectedName.toString(),
          selectedTargetParticipants.toString(),
          date
        ],
      );
      String finalMessage = baseMessage.replaceAll(RegExp(r'[{}]'), '');
      String url = await TCloudHelperFunctions.uploadAssetImage(
          "assets/images/content/create_sale_group.jpg", "create_sale_group");

      await NotificationService.instance.createAndSendNotification(
        title: lang.translate('create_group_success'),
        message: finalMessage,
        type: "sale_group",
        imageUrl: url,
      );
        resetData();
        return newGroup;
    } catch (e) {
      if (kDebugMode) {
        print("Error in submitReview: $e");
      }
    } finally {
      TLoader.successSnackbar(title: lang.translate('create_group_success'));
      TFullScreenLoader.stopLoading();
      Navigator.pop(context);
    }
   return null;
  }
  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }
}