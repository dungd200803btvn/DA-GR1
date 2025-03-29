import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/sizes.dart';

import '../../../navigation_menu.dart';

class TAnimationLoaderWidget extends StatelessWidget {
  const TAnimationLoaderWidget({
    super.key,
    required this.text,
    required this.animation,
    this.showAction = false,
    this.actionText,
    this.onActionPressed,
  });

  final String text, animation;
  final bool showAction;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              animation,
              width: MediaQuery.of(context).size.width * 0.8,
            ),
            const SizedBox(height: DSize.defaultspace),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSize.defaultspace),
            if (showAction)
              SizedBox(
                width: 250,
                child: OutlinedButton(
                  onPressed: onActionPressed ?? () {
                    final navController = Get.find<NavigationController>();
                    navController.goToHome();
                  },
                  style: OutlinedButton.styleFrom(backgroundColor: DColor.dark),
                  child: Text(
                    actionText!,
                    style: Theme.of(context).textTheme.bodyMedium!.apply(color: DColor.light),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
