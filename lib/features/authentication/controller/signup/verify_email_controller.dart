import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:app_my_app/common/widgets/success_screen/success_screen.dart';
import 'package:app_my_app/data/repositories/authentication/authentication_repository.dart';
import 'package:app_my_app/utils/constants/image_strings.dart';
import 'package:app_my_app/utils/popups/loader.dart';
import '../../../../l10n/app_localizations.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();
  var lang = AppLocalizations.of(Get.context!);
  //send email whenever verify screen appear and set timer for auto redirect
  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      TLoader.successSnackbar(
          title: lang.translate('send_email'),
          message: lang.translate('verify_email_msg'));
    } catch (e) {
      TLoader.errorSnackbar(title: lang.translate('snap'), message: e.toString());
    }
  }
  
  setTimerForAutoRedirect(){
    Timer.periodic(const Duration(seconds: 1), (timer) async{
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if(user?.emailVerified ?? false){
        timer.cancel();
        Get.off(
            () => SuccessScreen(
                image: TImages.successfullyRegisterAnimation,
                title: lang.translate('yourAccountCreatedTitle'),
                subTitle: lang.translate('yourAccountCreatedSubTitle'),
                onPressed: ()=> AuthenticationRepository.instance.screenRedirect(),
            )
        );
      }
    });
  }
  //manually check if email verified
checkEmailVerificationStatus() async{
    final currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser!=null && currentUser.emailVerified){
      Get.off(
              () => SuccessScreen(
            image: TImages.successfullyRegisterAnimation,
            title: lang.translate('yourAccountCreatedTitle'),
            subTitle: lang.translate('yourAccountCreatedSubTitle'),
            onPressed: ()=> AuthenticationRepository.instance.screenRedirect(),
          )
      );
    }
}

}
