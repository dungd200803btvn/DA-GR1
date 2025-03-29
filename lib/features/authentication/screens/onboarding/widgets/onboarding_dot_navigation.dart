import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:my_app/features/authentication/controller/onboarding/onboard_controller.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../../../utils/helper/helper_function.dart';
class onBoardingDotNavigation extends StatelessWidget {
  const onBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    final controller =OnBoardingController.instance;
    return Positioned(
      bottom: TDeviceUtils.getBottomNavigatorBarHeight()+25,
      left: DSize.defaultspace,
      child: SmoothPageIndicator(
          effect:ExpandingDotsEffect(
          activeDotColor: dark? DColor.light: DColor.darkContainer,
          dotHeight: 6),
          controller:controller.pageController,
          onDotClicked: controller.dotNavigationClick,
          count: 3),
    );
  }
}