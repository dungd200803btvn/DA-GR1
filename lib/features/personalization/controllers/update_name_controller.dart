import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/data/repositories/user/user_repository.dart';
import 'package:lcd_ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:lcd_ecommerce_app/features/personalization/screens/profile/profile.dart';
import 'package:lcd_ecommerce_app/utils/popups/loader.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helper/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';

class UpdateNameController extends GetxController{
  static UpdateNameController get instance =>Get.find();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUsernameFormKey = GlobalKey<FormState>();
  late AppLocalizations lang;
  @override
  void onInit() {
   initializeNames();
    super.onInit();

  }
  @override
  void onReady() {
    super.onReady();
    // Bây giờ Get.context đã có giá trị hợp lệ, ta mới khởi tạo lang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(Get.context!);
    });
  }
  Future<void> initializeNames() async{
    firstName.text = userController.user.value.firstName;
    lastName.text = userController.user.value.lastName;
  }
  Future<void> updateUserName() async{
    try{
      //start loading
      TFullScreenLoader.openLoadingDialog(lang.translate('update_in4'), TImages.docerAnimation);
      //Check internet connect
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      //FORM VALID
      if(!updateUsernameFormKey.currentState!.validate()){
        TFullScreenLoader.stopLoading();
        return;
      }
      //update first and last name in the firebase firestore
      Map<String,dynamic> name ={'FirstName':firstName.text.trim(),'LastName':lastName.text.trim()};
      await userRepository.updateSingleField(name);
      //update Rx User value
      UserController.instance.fetchUserRecord();

      //remove loader
      TFullScreenLoader.stopLoading();
      //show success 
      TLoader.successSnackbar(title: lang.translate('congratulations'),message: lang.translate('update_name'));
      //Move to previous screen
      Get.off(()=>const ProfileScreen());
    }catch(e){
      TFullScreenLoader.stopLoading();
      TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
    }
  }
}
