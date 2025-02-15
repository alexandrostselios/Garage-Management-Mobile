import 'package:flutter/material.dart';
import 'package:garage_management/utils/config_storage.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();
    await ConfigStorage.setLanguage(locale.languageCode); // Save selection
  }

  Future<void> _loadSavedLocale() async {
    String savedLanguage = await ConfigStorage.getLanguage();
    _locale = Locale(savedLanguage);
    notifyListeners();
  }

  static List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('el', ''),
  ];
}
