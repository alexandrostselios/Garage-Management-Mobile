import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garage_management/models/engineer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';  // For base64 encoding
import 'dart:typed_data';

import 'package:intl/intl.dart'; // For handling byte arrays

class EngineersPage extends StatefulWidget {
  const EngineersPage({super.key});

  @override
  State<EngineersPage> createState() => _EngineersPageState();
}

class _EngineersPageState extends State<EngineersPage> {
  late Future<List<Engineer>> engineers;

  // Fetch the engineers from the API
  Future<List<Engineer>> fetchEngineers() async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetEngineersToList/1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((jsonItem) => Engineer.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Failed to load engineers');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<List<String>> fetchEngineerSpeciality(int engineerID) async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetEngineerSpecialitiesByEngineerID/$engineerID/1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey("specialities") && jsonResponse["specialities"] is List) {
          List<String> specialities = List<String>.from(jsonResponse["specialities"]);
          return specialities;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load engineer specialities');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEngineer(Engineer engineer) async {
    try {
      final Map<String, dynamic> requestBody = {
        if (engineer.engineerName != null) 'EngineerName': engineer.engineerName,
        if (engineer.engineerSurname != null) 'EngineerSurname': engineer.engineerSurname,
        if (engineer.engineerEmail != null) 'EngineerEmail': engineer.engineerEmail,
        if (engineer.engineerModifiedDate != null)
          'ModifiedDate': engineer.engineerModifiedDate?.toIso8601String(),
        if (engineer.engineerPhoto.isNotEmpty) 'EngineerPhoto': engineer.engineerPhoto, // Assuming base64 string
        if (engineer.engineerHomePhone != null) 'EngineerHomePhone': engineer.engineerHomePhone,
        if (engineer.engineerMobilePhone != null) 'EngineerMobilePhone': engineer.engineerMobilePhone,
        if (engineer.engineerComment != null) 'EngineerComment': engineer.engineerComment,
        if (engineer.engineerPassword != null) 'EngineerPassword': engineer.engineerPassword, // Only if not null
        if (engineer.enableAccess != null) 'EnableAccess': engineer.enableAccess,
        if (engineer.lastLoginDate != null) 'LastLoginDate': engineer.lastLoginDate?.toIso8601String(),
        if (engineer.engineerSpecialities.isNotEmpty) 'EngineerSpecialitiesID': engineer.engineerSpecialities,
      };

      // Print the request body to the console for debugging
      print("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.put(
        Uri.parse('https://garagewebapi.eu/api/UpdateEngineer/${engineer.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("Engineer Updated OK");
        return;
      } else {
        throw Exception('Failed to update engineer specialities');
      }
    } catch (e) {
      rethrow;
    }
  }

  void _showSendEmailPopup(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.sendEmail),
        content: Text(AppLocalizations.of(context)!.sendEmailInfo + " $email?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.emailSentTo + " $email")),
              );
            },
            child: Text(AppLocalizations.of(context)!.send),
          ),
        ],
      ),
    );
  }

  void _showEngineerEditPopup(BuildContext context, Engineer engineer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController(text: engineer.engineerName);
        TextEditingController surnameController = TextEditingController(text: engineer.engineerSurname);
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editEngineer),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
              ),
              TextField(
                controller: surnameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.surname),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                updateEngineer(engineer);
                //Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    engineers = fetchEngineers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.engineersList)),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            engineers = fetchEngineers();
          });
        },
        child: FutureBuilder<List<Engineer>>(
          future: engineers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No engineers found'));
            } else {
              List<Engineer> engineers = snapshot.data!;
              return ListView.builder(
                itemCount: engineers.length,
                itemBuilder: (context, index) {
                  Engineer engineer = engineers[index];
                  Color rowColor = engineer.enableAccess == 1
                      ? Color(0xFFFAFCFE)
                      : (engineer.enableAccess == 2
                      ? Color(0xFFF0BE63)
                      : Color(0xFFACA8B3));

                  return Dismissible(
                    key: Key(engineer.engineerID.toString()),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.email, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        _showSendEmailPopup(context, engineer.engineerEmail);  // Right Swipe: Show Email Popup
                      } else if (direction == DismissDirection.startToEnd) {
                        _showEngineerEditPopup(context, engineer);  // Left Swipe: Show Edit Popup
                      }
                      return false;  // Prevent the item from being dismissed
                    },
                    child: GestureDetector(
                      onTap: () {
                        _showEngineerDetails(context, engineer);  // Keep the onTap functionality intact
                      },
                      child: Container(
                        color: rowColor,
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${engineer.engineerName} ${engineer.engineerSurname}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (engineer.engineerHomePhone.isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.home, size: 16),
                                        SizedBox(width: 8),
                                        Text(engineer.engineerHomePhone, style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      engineer.engineerEmail,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  if (engineer.engineerMobilePhone.isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone, size: 16),
                                        SizedBox(width: 8),
                                        Text(engineer.engineerMobilePhone, style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _showEngineerDetails(BuildContext context, Engineer engineer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<String>>(
          future: fetchEngineerSpeciality(engineer.engineerID),
          builder: (context, snapshot) {
            List<String> specialities = snapshot.data ?? [];
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.engineerDetails),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(AppLocalizations.of(context)!.engineerID, engineer.engineerID.toString()),
                  _buildDetailRow(AppLocalizations.of(context)!.surname, engineer.engineerSurname),
                  _buildDetailRow(AppLocalizations.of(context)!.name, engineer.engineerName),
                  _buildDetailRow(AppLocalizations.of(context)!.engineerComments, engineer.engineerComment),
                  _buildDetailRow(AppLocalizations.of(context)!.enableAccess, _getAccessStatus(engineer.enableAccess)),
                  _buildDetailRow(AppLocalizations.of(context)!.lastLoginDate, engineer.lastLoginDate != null ? DateFormat('dd-MM-yyyy HH:mm').format(engineer.lastLoginDate!) : "-"),
                  _buildDetailRow(AppLocalizations.of(context)!.modifiedDate, engineer.engineerModifiedDate != null ? DateFormat('dd-MM-yyyy HH:mm').format(engineer.engineerModifiedDate!) : "-"),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.engineerSpecialities + ":", style: TextStyle(fontWeight: FontWeight.bold)),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    Center(child: CircularProgressIndicator())
                  else if (specialities.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: specialities.map((speciality) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Text("- $speciality", style: TextStyle(fontSize: 14)),
                          ),
                      ).toList(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text("-"),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  String _getAccessStatus(int access) {
    if (access == 1) return AppLocalizations.of(context)!.enabledAccess;
    if (access == 2) return AppLocalizations.of(context)!.restrictedAccess;
    return AppLocalizations.of(context)!.disabledAccess;
  }
}
