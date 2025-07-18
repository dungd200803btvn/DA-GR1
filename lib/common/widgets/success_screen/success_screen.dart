import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:app_my_app/common/styles/spacing_styles.dart';
import 'package:app_my_app/l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_string.dart';
import '../../../utils/helper/helper_function.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen(
      {super.key,
      required this.image,
      required this.title,
      required this.subTitle,
       this.onPressed});

  final String image, title, subTitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppbarHeight * 2,
          child: Column(
            children: [
              Lottie.asset(
                image,
                width: DHelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(
                height: DSize.spaceBtwSection,
              ),
              //Title ans Subtitle
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: DSize.spaceBtwItem,
              ),
              Text(
                subTitle,
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
                    onPressed: onPressed,
                    child: Text(lang.translate('tContinue'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
