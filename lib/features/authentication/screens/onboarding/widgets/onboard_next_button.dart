import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_app/features/authentication/controller/onboarding/onboard_controller.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../../../utils/helper/helper_function.dart';
class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = DHelperFunctions.isDarkMode(context);
    return Positioned(
        right: DSize.defaultspace,
        bottom: TDeviceUtils.getBottomNavigatorBarHeight(),
        child: ElevatedButton(
          onPressed: () =>OnBoardingController.instance.nextButton(),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: dark? DColor.primary:Colors.black,
          ),
          child: const Icon(Iconsax.arrow_right_3),
        ));
  }
}
