import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:t_store_app/data/repositories/authentication/authentication_repository.dart';
import 'package:t_store_app/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:t_store_app/utils/constants/image_strings.dart';
import 'package:t_store_app/utils/popups/full_screen_loader.dart';
import 'package:t_store_app/utils/popups/loader.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/helper/network_manager.dart';

class ForgetPasswordController  extends GetxController{
  static ForgetPasswordController get instance => Get.find();
  //variables
  final email = TextEditingController();
  var lang = AppLocalizations.of(Get.context!);
  void init() async{
    //start loading
    TFullScreenLoader.openLoadingDialog(lang.translate('process_request'), TImages.docerAnimation);
    //Check internet connect
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TFullScreenLoader.stopLoading();
      return;
    }
  }
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();
   sendPasswordResentEmail() async{
    try{
      init();
      //form validation
      if(!forgetPasswordFormKey.currentState!.validate()){
        TFullScreenLoader.stopLoading();
        return;
      }
      //call api
      await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());
      //remove loader
      TFullScreenLoader.stopLoading();
      //show success screen
      TLoader.successSnackbar(title: lang.translate('send_email'),message: lang.translate('send_email_msg'));//dich sang ngon ngu hien tai dang dung trong app
      //redirect screen
      Get.to(()=> ResetPassword(email:  email.text.trim(),));
    }catch(e){
      TFullScreenLoader.stopLoading();
      TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
    }
  }
    resendPasswordResentEmail(String email) async{
    try{
        init();
      //call api
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);
      //remove loader
      TFullScreenLoader.stopLoading();
      //show success screen
        TLoader.successSnackbar(title: lang.translate('send_email'),message: lang.translate('send_email_msg'));//dich sang ngon ngu hien tai dang dung trong app
      //redirect screen

    }catch(e){
      TFullScreenLoader.stopLoading();
      TLoader.errorSnackbar(title: lang.translate('snap'),message: e.toString());
    }
  }
}