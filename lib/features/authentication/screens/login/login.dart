import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_my_app/common/styles/spacing_styles.dart';
import 'package:app_my_app/common/widgets/login_signup/login_divider.dart';
import 'package:app_my_app/features/authentication/screens/login/widgets/login_form.dart';
import 'package:app_my_app/features/authentication/screens/login/widgets/login_header.dart';
import 'package:app_my_app/common/widgets/login_signup/login_social_buttons.dart';
import 'package:app_my_app/utils/constants/text_string.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/login/login_controller.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: TSpacingStyle.paddingWithAppbarHeight,
      child: Column(
        children: [
          //1. Header
          const TLoginHeader(),
          //2. Form
          const TLoginForm(),
          //3. Divider
          TFormDivider(dividerText: lang.translate('orSignInWith'),),
          const SizedBox(
            height: DSize.spaceBtwSection,
          ),
          //4. Footer
          const TSocialButtons()
        ],
      ),
    )));
  }
}
