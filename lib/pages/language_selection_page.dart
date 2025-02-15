import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'home_page.dart';
import 'locale_provider.dart';
import '../models/userLogin.dart';
import '../utils/config_storage.dart'; // Import the storage helper

class LanguageSelectionPage extends StatelessWidget {
  final UserLogin userLogin;

  const LanguageSelectionPage({super.key, required this.userLogin});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    print("Current Locale: $locale");

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectLanguage),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Image.asset('assets/flags/usa.png'),
            title: Text(localizations.english),
            onTap: () async {
              // Change the locale
              Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('en', ''));

              // Save selection
              await ConfigStorage.setLanguage('en');

              // Navigate to MyHomePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(
                    title: 'My Home Page',
                    userLogin: userLogin,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Image.asset('assets/flags/greece.png'),
            title: Text(localizations.greek),
            onTap: () async {
              // Change the locale
              Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('el', ''));

              // Save selection
              await ConfigStorage.setLanguage('el');

              // Navigate to MyHomePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(
                    title: 'My Home Page',
                    userLogin: userLogin,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
