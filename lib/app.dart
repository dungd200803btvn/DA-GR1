
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:t_store/bindings/general_bindings.dart';
import 'package:t_store/routes/app_routes.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/theme/theme.dart';
import 'features/setting/controllers/language_controller.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.put(LanguageController());
    return Obx(()=>GetMaterialApp(
      title: 'Ecommerce App',
      themeMode: Get.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: DAppTheme.dark_theme,
      theme: DAppTheme.light_theme,
      initialBinding: GeneralBindings(),
      getPages: AppRoutes.pages,
      navigatorKey: navigatorKey,
      locale: languageController.locale.value,// Mặc định là tiếng Anh
      supportedLocales: const [
        Locale('en', ''), // Tiếng Anh
        Locale('vi', ''), // Tiếng Việt
      ],
      localizationsDelegates:  const [
        AppLocalizations.delegate, // Thêm delegate tùy chỉnh
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Scaffold(backgroundColor: DColor.primary,body: Center(child: CircularProgressIndicator(color: DColor.white,),),),
    ) );

  }
}
