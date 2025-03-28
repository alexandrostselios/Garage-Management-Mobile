import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garage_management/pages/login_page.dart';
import 'package:garage_management/pages/home_page.dart';
import 'package:garage_management/pages/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/utils/config_storage.dart';

import 'models/userLogin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures async calls can be made
  String savedLanguage = await ConfigStorage.getLanguage();
  int loginStatus = await ConfigStorage.getLoginStatus();
  print("Main Language: $savedLanguage ==== Login Status: $loginStatus");

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider()..setLocale(Locale(savedLanguage)),
      child: MyApp(loginStatus: loginStatus),
    ),
  );
}

class MyApp extends StatelessWidget {
  final int loginStatus;

  const MyApp({super.key, required this.loginStatus});

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
      home: loginStatus == 1
          ? MyHomePage(title: "Garage Management (Mobile)", userLogin: UserLogin(success: "true", id: 1, email: "admin@garage.com", surname: "Doe", name: "John", userType: 1, garageID: 101))
          : LoginPage(), // If already logged in, go to HomePage
    );
  }
}
