import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_my_app/features/authentication/controller/onboarding/onboard_controller.dart';
import 'package:app_my_app/features/authentication/screens/onboarding/widgets/onboard_next_button.dart';
import 'package:app_my_app/features/authentication/screens/onboarding/widgets/onboard_skip.dart';
import 'package:app_my_app/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:app_my_app/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:app_my_app/utils/constants/image_strings.dart';
import 'package:app_my_app/utils/constants/text_string.dart';

import '../../../../l10n/app_localizations.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    var lang = AppLocalizations.of(context);
    return  Scaffold(
      body: Stack(
        children: [
          //Horizon Page scroll view
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnboardingWidget(
                image: TImages.onBoardingImage1,
                title: lang.translate('onBoardingTitle1'),
                subTitle: lang.translate('onBoardingSubTitle1'),
              ),
              OnboardingWidget(
                image: TImages.onBoardingImage2,
                title: lang.translate('onBoardingTitle2'),
                subTitle: lang.translate('onBoardingSubTitle2'),
              ),
              OnboardingWidget(
                image: TImages.onBoardingImage3,
                title: lang.translate('onBoardingTitle3'),
                subTitle: lang.translate('onBoardingSubTitle3'),
              ),
            ],
          ),
          
          //Skip button
            const onBoardingSkip(),
          //Dot navigation SmoothPageIndicator
         const onBoardingDotNavigation(),
        //circular Button
          const OnBoardingNextButton()
        ],
      ),
    );
  }
}







