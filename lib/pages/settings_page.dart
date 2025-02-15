import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'locale_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!; // Fetch localized strings
    final locale = Localizations.localeOf(context);
    print("Current Locale: $locale");
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings), // Use localized string for app bar title
      ),
      body: Column(
        children: [
          // Add more languages and flags here
        ],
      ),
    );
  }
}
