import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_my_app/features/authentication/controller/forget_password/forget_password_controller.dart';
import 'package:app_my_app/features/authentication/screens/login/login.dart';
import 'package:app_my_app/utils/constants/image_strings.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/constants/text_string.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/helper/helper_function.dart';
class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key, required this.email});
final String email;
  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(CupertinoIcons.clear)),
        ],
      ),
      body:  SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(DSize.defaultspace),
        child: Column(
          children: [
            Image(
              image: const AssetImage(TImages.deliveredEmailIllustration),
              width: DHelperFunctions.screenWidth() * 0.6,
            ),
            const SizedBox(
              height: DSize.spaceBtwSection,
            ),
            //Title ans Subtitle
            Text(
              lang.translate('changeYourPasswordTitle'),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: DSize.spaceBtwItem,
            ),
            Text(
              lang.translate('changeYourPasswordSubTitle'),
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: DSize.spaceBtwSection,
            ),
            //Button quay lai login sau khi xac minh email thanh cong
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  child:  Text(lang.translate('done')), onPressed: ()=> Get.offAll(()=> const LoginScreen())),
            ),
            const SizedBox(
              height: DSize.spaceBtwItem,
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                  child: Text(lang.translate('resendEmail')), onPressed: ()=> ForgetPasswordController.instance.resendPasswordResentEmail(email)),
            ),

          ],
        ),),
      ),
    );
  }
}
