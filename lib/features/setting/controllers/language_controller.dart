import 'dart:ui';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  var locale = const Locale('en').obs; // Mặc định là tiếng Anh
  void changeLanguage(Locale newLocale) {
    locale.value = newLocale;
    Get.updateLocale(newLocale); // Cập nhật ngôn ngữ cho toàn bộ app
  }
}