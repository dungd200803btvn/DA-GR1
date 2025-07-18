import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:app_my_app/features/personalization/controllers/user_controller.dart';
import 'package:app_my_app/utils/constants/sizes.dart';
import 'package:app_my_app/utils/constants/text_string.dart';
import 'package:app_my_app/utils/validators/validation.dart';

import '../../../../../l10n/app_localizations.dart';
class ReAuthLoginForm extends StatelessWidget {
  const ReAuthLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title:  Text(lang.translate('re_auth')),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Form(
            key: controller.reAuthFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Email
                TextFormField(
                  controller: controller.verifyEmail,
                  validator: (value)=>DValidator.validateEmail(value),
                  decoration:  InputDecoration(prefixIcon: Icon(Iconsax.direct_right),labelText: lang.translate('email')),
                ),
                const SizedBox(height: DSize.spaceBtwInputFielRadius,),
                ///Password
                Obx(() => TextFormField(
                  obscureText: controller.hidePassword.value,
                  controller: controller.verifyPassword,
                  validator: (value)=> DValidator.validatePassword(value),
                  decoration: InputDecoration(
                    labelText: lang.translate('password'),
                    prefixIcon: const Icon(Iconsax.password_check),
                    suffixIcon: IconButton(
                      onPressed: ()=> controller.hidePassword.value = !controller.hidePassword.value ,
                      icon: Icon( controller.hidePassword.value?Iconsax.eye_slash : Iconsax.eye),
                    )
                  ),
                )),
                const SizedBox(height: DSize.spaceBtwSection,),
              //Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: ()=>controller.reAuthenticateEmailAndPasswordUser(),child:  Text(lang.translate('verify')),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
