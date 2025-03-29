import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/helper/helper_function.dart';

class TLoader {
  static hideSnackBar() =>
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: DHelperFunctions.isDarkMode(Get.context!)
                  ? DColor.darkerGrey.withOpacity(0.9)
                  : DColor.grey.withOpacity(0.9)),
          child: Center(
            child: Text(
              message,
              style: Theme.of(Get.context!).textTheme.labelLarge,
            ),
          ),
        ),
      ),
    );
  }

  static successSnackbar({required title, message = ''}) {
    Get.snackbar(title, message,
        isDismissible: true,
        //co the đóng bằng cách bấm nút x không
        shouldIconPulse: true,
        //biểu tượng cảnh báo có nhấp nháy không
        colorText: DColor.white,
        backgroundColor: DColor.primary,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(10),
        icon: const Icon(
          Iconsax.check,
          color: DColor.white,
        ) //biểu tượng bên trái snack bar
        );
  }

  static warningSnackbar({required title, message = ''}) {
    Get.snackbar(title, message,
        isDismissible: true,
        //co the đóng bằng cách bấm nút x không
        shouldIconPulse: true,
        //biểu tượng cảnh báo có nhấp nháy không
        colorText: DColor.white,
        backgroundColor: Colors.orange,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(20),
        icon: const Icon(
          Iconsax.warning_2,
          color: DColor.white,
        ) //biểu tượng bên trái snack bar
        );
  }

  static errorSnackbar({required title, message = ''}) {
    Get.snackbar(title, message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: DColor.white,
        backgroundColor: Colors.red.shade600,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(20),
        icon: const Icon(
          Iconsax.warning_2,
          color: DColor.white,
        ));
  }
}
