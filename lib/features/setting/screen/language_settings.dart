import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/language_controller.dart';

class LanguageSelectorScreen extends StatelessWidget {
  const LanguageSelectorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    final LanguageController languageController = Get.find();
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          lang.translate('language_setting'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(lang.translate('vi')),
            onTap: () {
              // Khi người dùng chọn Tiếng Việt, gọi callback
              languageController.changeLanguage(const Locale('vi'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(lang.translate('en')),
            onTap: () {
              // Khi người dùng chọn Tiếng Việt, gọi callback
              languageController.changeLanguage(const Locale('en'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
