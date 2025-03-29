import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lcd_ecommerce_app/features/authentication/controller/signup/signup_controller.dart';
import 'package:lcd_ecommerce_app/features/authentication/screens/signup/widgets/term_condition_checkbox.dart';
import 'package:lcd_ecommerce_app/utils/validators/validation.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_string.dart';

class TSignupForm extends StatelessWidget {
  const TSignupForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    var lang = AppLocalizations.of(context);
    return Form(
        key: controller.signupFormKey,
        child: Column(
          children: [
            //First and last name
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.firstName,
                    validator: (value) =>
                        DValidator.validateEmptyText('First Name', value),
                    decoration:  InputDecoration(
                        labelText: lang.translate('firstName'),
                        prefixIcon: Icon(Iconsax.user)),
                    expands: false,
                  ),
                ),
                const SizedBox(
                  width: DSize.spaceBtwItem,
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller.lastName,
                    validator: (value) =>
                        DValidator.validateEmptyText('lastName', value),
                    decoration:  InputDecoration(
                        labelText: lang.translate('lastName'),
                        prefixIcon: Icon(Iconsax.user)),
                    expands: false,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: DSize.spaceBtwInputFielRadius,
            ),
            TextFormField(
              controller: controller.userName,
              validator: (value) =>
                  DValidator.validateEmptyText('userName', value),
              decoration:  InputDecoration(
                  labelText: lang.translate('username'),
                  prefixIcon: Icon(Iconsax.user_edit)),
              expands: false,
            ),
            const SizedBox(
              height: DSize.spaceBtwInputFielRadius,
            ),

            //Email
            TextFormField(
              controller: controller.email,
              validator: (value) => DValidator.validateEmail(value),
              decoration:  InputDecoration(
                  labelText: lang.translate('email'),
                  prefixIcon: Icon(Iconsax.direct)),
            ),
            const SizedBox(
              height: DSize.spaceBtwInputFielRadius,
            ),
            //Phone number
            TextFormField(
              controller: controller.phoneNumber,
              validator: (value) => DValidator.validatePhoneNumber(value),
              decoration:  InputDecoration(
                  labelText: lang.translate('phoneNo'),
                  prefixIcon: Icon(Iconsax.call)),
            ),
            const SizedBox(
              height: DSize.spaceBtwInputFielRadius,
            ),
            //Password
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) => DValidator.validatePassword(value),
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
            const SizedBox(
              height: DSize.spaceBtwInputFielRadius,
            ),

            //Term && Condition Checkbox
            const TTermsAndConditionCheckBox(),
            const SizedBox(
              height: DSize.spaceBtwSection,
            ),
            //Signup button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.signup(),
                child:  Text(lang.translate('createAccount')),
              ),
            ),
          ],
        ));
  }
}
