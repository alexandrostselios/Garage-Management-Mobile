import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garage_management/pages/login_page.dart';
import 'package:garage_management/pages/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/utils/config_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures async calls can be made
  String savedLanguage = await ConfigStorage.getLanguage();
  String login = await ConfigStorage.getLoginStatus();
  print("Main Language: $savedLanguage ==== Login Status: $login");
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider()..setLocale(Locale(savedLanguage)),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Garage Management',
      locale: localeProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleProvider.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginPage(), // Set LoginPage as the first screen
    );
  }
}
