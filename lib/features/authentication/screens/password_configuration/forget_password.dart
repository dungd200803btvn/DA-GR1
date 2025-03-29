import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_app/features/authentication/controller/forget_password/forget_password_controller.dart';
import 'package:my_app/utils/constants/sizes.dart';
import 'package:my_app/utils/constants/text_string.dart';
import 'package:my_app/utils/validators/validation.dart';

import '../../../../l10n/app_localizations.dart';
class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    var lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(DSize.defaultspace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Heading
            Text(lang.translate('forgetPasswordTitle'),style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: DSize.spaceBtwItem),
            Text(lang.translate('forgetPasswordSubTitle'),style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: DSize.spaceBtwSection*2),
            //Textfield
            //Email
            Form(
              key: controller.forgetPasswordFormKey,
              child: TextFormField(controller: controller.email,
                  validator: (value) => DValidator.validateEmail(value),
                  decoration:  InputDecoration(labelText: lang.translate('email'),prefixIcon: Icon(Iconsax.direct_right))),
            ),
            const SizedBox(height: DSize.spaceBtwSection),
            
            //Submit Button
            SizedBox(width: double.infinity,
                child: ElevatedButton( onPressed: () async {
                  await controller.sendPasswordResentEmail();
                }, child: Text(lang.translate('submit'))))
          ],
        ),


        
      ),
    );
  }
}
