import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garage_management/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/carManufacter.dart';
import '../models/userLogin.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'locale_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController(text: "admin@garage.com");
  final TextEditingController _passwordController = TextEditingController(text: "a1");
  //final TextEditingController _usernameController = TextEditingController();
  //final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static int garageID = 1;
  late UserLogin userLogin;

  Future<void> _login() async {
    // Ensure the form is validated before proceeding
    if (_formKey.currentState!.validate()) {
      bool isLogin = await fetchUserLogin();
      // Mock login check (replace with real authentication logic)
      if (isLogin) {
        // If credentials are valid, navigate to the HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
                title: "Garage Management (Mobile)",
                userLogin: userLogin, // Pass the userLogin object here
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Credentials")),
        );
      }
    }
  }

  // API Call
  Future<bool> fetchUserLogin() async {
    print("Fetch User Login");
    String uri = 'https://garagewebapi.eu/api/GetLogin/${_usernameController.text}/${_passwordController.text}/${garageID}';
    try {
      final response = await http.get(
        Uri.parse(uri),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print("API Request Sent");
      print("Uri $uri");
      print("Response: ${response.statusCode}");
      if (response.statusCode == 200 || response.toString() =='Login') {
        print("Response Received: ${response.body}");
        if(await fetchUserLoginDetails()){
          return true;
        }
        return false;
      } else {
        print("API Error: Status Code ${response.statusCode}");
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print("Error during fetchUsers: $e");
      throw e;
    }
  }

  Future<bool> fetchUserLoginDetails() async {
    print("Fetch User Login Details");
    String uri = 'https://garagewebapi.eu/api/GetUserByEmailAndPassword/${_usernameController.text}/${_passwordController.text}/${garageID}';
    try {
      final response = await http.get(
        Uri.parse(uri),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print("User Login Details Uri $uri");
      print("User Login Details Response: ${response.statusCode}");
      if (response.statusCode == 200 || response.toString() =='Login') {
        print("User Login Details Response Received: ${response.body}");

        // Decode the response body into a Map
        Map<String, dynamic> responseJson = json.decode(response.body);

        // Create a UserLogin object with data from the response
        userLogin = UserLogin(
          success: responseJson['success'] ?? "false", // If 'success' is null, assign a default value
          id: responseJson['id'] ?? 0, // Default to 0 if 'id' is missing
          email: _usernameController.text, // You can still use the email from your controller
          surname: responseJson['surname'] ?? "Doe", // Default to "Doe" if not found
          name: responseJson['name'] ?? "John", // Default to "John" if not found
          userType: responseJson['userType'] ?? 1, // Default to 1 if 'userType' is missing
          garageID: responseJson['garageID'] ?? 101, // Default to 101 if 'garageID' is missing
        );

        return true;
      } else {
        print("API Error: Status Code ${response.statusCode}");
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print("Error during fetchUserLoginDetails: $e");
      throw e;
    }
  }


  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjust the body when the keyboard is shown
      body: SingleChildScrollView( // Make the whole body scrollable
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height, // Ensure full screen height
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.blue[900]!,
                Colors.white,
                Colors.blue[400]!
              ],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 80),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Text(AppLocalizations.of(context)!.login, style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    //SizedBox(height: 10),
                    Text(AppLocalizations.of(context)!.welcome, style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Form widget to handle validation
              Form(
                key: _formKey, // Global key for form
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 60),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(225, 95, 27, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              // Email input field
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                                ),
                                child: TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    hintText: "Email",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!.enterEmail;
                                    }
                                    return null;
                                  },
                                  // Set the action for the keyboard to "Next"
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              // Password input field
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.password,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!.enterPassword;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        // Login button
                        Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 50),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.orange,
                          ),
                          child: InkWell(
                            onTap: _login, // Calls _login function on tap
                            borderRadius: BorderRadius.circular(50), // Match container's radius
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.login,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}