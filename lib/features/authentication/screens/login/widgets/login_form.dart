import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:app_my_app/features/authentication/controller/login/login_controller.dart';
import 'package:app_my_app/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:app_my_app/features/authentication/screens/signup/signup.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import 'package:app_my_app/utils/validators/validation.dart';
import '../../../../../utils/constants/sizes.dart';
class TLoginForm extends StatelessWidget {
  const TLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    var lang = AppLocalizations.of(context);
    return Form(
      key: controller.loginFormKey,
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: DSize.spaceBtwSection),
      child: Column(
        children: [


          //Email
          TextFormField(
            controller: controller.email,
            validator: (value)=> DValidator.validateEmail(value),
            decoration:  InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: lang.translate('email'
            ),
          ),
      ),
          const SizedBox(height: DSize.spaceBtwInputFielRadius,),

          //Password
          Obx(
                () => TextFormField(
              controller: controller.password,
              validator: (value) => DValidator.validateEmptyText("Password",value),
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                labelText: lang.translate('password'),
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidePassword.value =
                  !controller.hidePassword.value,
                  icon: Icon( controller.hidePassword.value?Iconsax.eye_slash : Iconsax.eye),
                ),
              ),
            ),
          ),

          const SizedBox(height: DSize.spaceBtwInputFielRadius/2,),
          //Remember me va Forgot Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Remember me
              Row(
                children: [
                  Obx(
              ()=> Checkbox(value: controller.rememberMe.value,
                      onChanged: (value)=> controller.rememberMe.value=!controller.rememberMe.value,),
                  ),
                   Text(lang.translate('rememberMe'))
                ],
              ),
              //Forgot Button
              TextButton(onPressed: ()=>Get.to(()=> const ForgetPassword()), child:  Text(lang.translate('forgetPassword')))

            ],
          ),
          const SizedBox(height: DSize.spaceBtwSection,),
          //Signin Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async{
                controller.emailAndPasswordLogin();
              },
              child:  Text(lang.translate('signIn')),
            ),
          ),
          const SizedBox(height: DSize.spaceBtwSection,),
          //Create Action Button

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(()=> const Signup()),
              child:  Text(lang.translate('createAccount')),
            ),
          )
        ],
      ),
    ));
  }
}