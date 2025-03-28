import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garage_management/pages/appointments_page.dart';
import 'package:garage_management/pages/customers_page.dart';
import 'package:garage_management/pages/employees_page.dart';
import 'package:garage_management/pages/engineers_page.dart';
import 'package:garage_management/pages/language_selection_page.dart';
import 'package:garage_management/pages/myAccount_page.dart';
import 'package:garage_management/pages/settings_page.dart';
import 'package:garage_management/pages/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/userLogin.dart';
import '../utils/config_storage.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final UserLogin userLogin; // Add the userLogin parameter

  const MyHomePage({super.key, required this.title,  required this.userLogin});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Track which page to show

  // List of pages to display inside the body
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();

    // Initialize the _pages list with the default pages
    _pages = [
      Center(child: Text('Home Page Content')), // Default home page content
      CustomersPage(), // Customers page
      EngineersPage(), // Engineers page
      EmployeesPage(), // Employees page
      ServiceAppointmentsPage(), // Appointments page
      MyAccountPage(), // My Account page
      SettingsPage(), // Settings page
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically add the LanguageSelectionPage with the required userLogin parameter
    _pages.add(LanguageSelectionPage(userLogin: widget.userLogin));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        backgroundColor: Colors.deepPurple[100],
        child: Column(
          children: [
            DrawerHeader(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.welcome + '\n${widget.userLogin.surname} ${widget.userLogin.name}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  softWrap: true,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.home),
              title: Text(AppLocalizations.of(context)!.home),
              onTap: () => _onItemTapped(0),
            ),
            if (widget.userLogin.userType == 2) ...[
              ListTile(
                leading: const Icon(FontAwesomeIcons.calendarDays),
                title: Text(AppLocalizations.of(context)!.appointments),
                onTap: () => _onItemTapped(4),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.userCircle),
                title: Text(AppLocalizations.of(context)!.myAccount),
                onTap: () => _onItemTapped(5),
              ),
            ] else ...[
              ListTile(
                leading: const Icon(FontAwesomeIcons.users),
                title: Text(AppLocalizations.of(context)!.customers),
                onTap: () => _onItemTapped(1),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.wrench),
                title: Text(AppLocalizations.of(context)!.engineers),
                onTap: () => _onItemTapped(2),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.userGear),
                title: Text(AppLocalizations.of(context)!.employees),
                onTap: () => _onItemTapped(3),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.calendarDays),
                title: Text(AppLocalizations.of(context)!.appointments),
                onTap: () => _onItemTapped(4),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.userCircle),
                title: Text(AppLocalizations.of(context)!.myAccount),
                onTap: () => _onItemTapped(5),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.gear),
                title: Text(AppLocalizations.of(context)!.settings),
                onTap: () => _onItemTapped(6),
              ),
            ],
            ListTile(
              leading: const Icon(FontAwesomeIcons.globe),
              title: Text(AppLocalizations.of(context)!.language),
              onTap: () => _onItemTapped(7),
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.lock),
              title: Text(AppLocalizations.of(context)!.logout),
              onTap: () async {
                // Save selection
                await ConfigStorage.setLoginStatus(0);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // This dynamically switches the content
    );
  }

  void _onItemTapped(int index) {
    Navigator.pop(context); // Closes the drawer
    setState(() {
      _selectedIndex = index;
    });
  }
}
