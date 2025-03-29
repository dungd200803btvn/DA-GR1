import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store_app/features/authentication/controller/signup/signup_controller.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_string.dart';
import '../../../../../utils/helper/helper_function.dart';

class TTermsAndConditionCheckBox extends StatelessWidget {
  const TTermsAndConditionCheckBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;
    final dark = DHelperFunctions.isDarkMode(context);
    var lang = AppLocalizations.of(context);
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(
            () => Checkbox(
              value: controller.privacyPolacy.value,
              onChanged: (value) => controller.privacyPolacy.value =
                  !controller.privacyPolacy.value,
            ),
          ),
        ),
        const SizedBox(
          width: DSize.spaceBtwItem,
        ),
        Text.rich(TextSpan(children: [
          TextSpan(
            text: lang.translate('iAgreeTo'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextSpan(
            text: " ${lang.translate('privacyPolicy')}",
            style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? DColor.white : DColor.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? DColor.white : DColor.primary,
                ),
          ),
          TextSpan(
            text: " ${lang.translate('and')}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextSpan(
            text: " ${lang.translate('termsOfUse')}",
            style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? DColor.white : DColor.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? DColor.white : DColor.primary,
                ),
          ),
        ])),
      ],
    );
  }
}
