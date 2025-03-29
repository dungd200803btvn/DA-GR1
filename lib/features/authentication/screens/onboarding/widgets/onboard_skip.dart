import 'package:flutter/material.dart';
import 'package:app_my_app/features/authentication/controller/onboarding/onboard_controller.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';
class onBoardingSkip extends StatelessWidget {
  const onBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(top: TDeviceUtils.getAppBarHeight(),
        right: DSize.defaultspace,
        child: TextButton(
          onPressed: () =>OnBoardingController.instance.skipButton(),
          child: const Text("Skip"),
        ));
  }
}