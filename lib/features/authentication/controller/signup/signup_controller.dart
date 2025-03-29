import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/data/repositories/authentication/authentication_repository.dart';
import 'package:lcd_ecommerce_app/data/repositories/user/user_repository.dart';
import 'package:lcd_ecommerce_app/features/authentication/screens/signup/verify_email.dart';
import 'package:lcd_ecommerce_app/l10n/app_localizations.dart';
import 'package:lcd_ecommerce_app/utils/popups/full_screen_loader.dart';
import 'package:lcd_ecommerce_app/utils/popups/loader.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helper/network_manager.dart';
import '../../models/user_model.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();
  ///Variables
  final hidePassword = true.obs;
  final privacyPolacy = true.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final userName = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final phoneNumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  var lang = AppLocalizations.of(Get.context!);
  /// Signup
  void signup() async {
    try {
      //Start loading
      TFullScreenLoader.openLoadingDialog(
          lang.translate('process_info'), TImages.docerAnimation);
      //Check internet connect
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      //Form Validation
      if (!signupFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      //Privacy Policy check
      if (!privacyPolacy.value) {
        TLoader.warningSnackbar(
            title: lang.translate('accept_privacy'),
            message:
            lang.translate('accept_privacy_msg'));
        return;
      }
      //register user in the Firebase Authentication and save in the firebase
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim());
      //save Authenticated user data in the Firebase Firestore
      final newUser = UserModel(
          userCredential.user!.uid,
          firstName.text.trim(),
          lastName.text.trim(),
          userName.text.trim(),
          email.text.trim(),
          phoneNumber.text.trim(),
          "");
      final userRepository = Get.put(UserRepository());
      await  userRepository.saveUserRecord(newUser);
    //Show Success Message
      TFullScreenLoader.stopLoading();
      TLoader.successSnackbar(title: lang.translate('accept_privacy'),message: lang.translate('accept_privacy_msg'));
      Get.to(()=>  VerifyEmailScreen(email: email.text.trim(),));
    } catch (e) {
      TLoader.errorSnackbar(title: lang.translate('snap'), message: e.toString());
      TFullScreenLoader.stopLoading();
      return;
    }
  }
}
