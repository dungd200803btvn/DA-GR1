
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcd_ecommerce_app/common/widgets/login_signup/login_divider.dart';
import 'package:lcd_ecommerce_app/common/widgets/login_signup/login_social_buttons.dart';
import 'package:lcd_ecommerce_app/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:lcd_ecommerce_app/l10n/app_localizations.dart';
import 'package:lcd_ecommerce_app/utils/constants/sizes.dart';
import 'package:lcd_ecommerce_app/utils/constants/text_string.dart';
import 'package:lcd_ecommerce_app/utils/helper/helper_function.dart';
class Signup extends StatelessWidget {
  const Signup({super.key});
  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSize.defaultspace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Title
              Text(lang.translate('signupTitle'),style: Theme.of(context).textTheme.headlineMedium,),
              const SizedBox(height: DSize.spaceBtwSection,),
              //Form
              const TSignupForm(),
              const SizedBox(
                height: DSize.spaceBtwSection,
              ),
              //Divider
              TFormDivider(dividerText: lang.translate('orSignInWith').capitalize!),
              //Social button
              const TSocialButtons(),
              const SizedBox(
                height: DSize.spaceBtwSection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

