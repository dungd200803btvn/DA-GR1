
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:t_store/bindings/general_bindings.dart';
import 'package:t_store/routes/app_routes.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/theme/theme.dart';

import 'main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      darkTheme: DAppTheme.dark_theme,
      theme: DAppTheme.light_theme,
      initialBinding: GeneralBindings(),
      getPages: AppRoutes.pages,
      navigatorKey: navigatorKey,
      home: const Scaffold(backgroundColor: DColor.primary,body: Center(child: CircularProgressIndicator(color: DColor.white,),),),
    );
  }
}