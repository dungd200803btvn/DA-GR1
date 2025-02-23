import 'dart:ui';

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale as Locale);

  @override
  String get hello => 'Hello';

  @override
  String get welcome => 'Welcome to our app';
}
