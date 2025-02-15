import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garage_management/models/engineer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/models/engineer.dart'; // Import the Customer model

class EngineersPage extends StatefulWidget {
  const EngineersPage({super.key});

  @override
  State<EngineersPage> createState() => _EngineersPageState();
}

class _EngineersPageState extends State<EngineersPage> {
  late Future<List<Engineer>> engineers;

  // Fetch the customers from the API
  Future<List<Engineer>> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetEngineersToList/1'), // Pass the appropriate garageID if needed
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Engineer Status OK");
        // If the server returns a successful response (200), parse the response
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((jsonItem) => Engineer.fromJson(jsonItem)).toList();
      } else {
        // If the server doesn't return a successful response, throw an exception
        throw Exception('Failed to load engineers');
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      print("Error fetching engineers: $e");
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    engineers = fetchCustomers(); // Fetch customers when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.engineers),
      ),
      body: FutureBuilder<List<Engineer>>(
        future: engineers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while the data is being fetched
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if something went wrong
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if no customers are found
            return Center(child: Text('No engineers found'));
          } else {
            // Display the list of customers
            List<Engineer> engineers = snapshot.data!;

            return ListView.builder(
              itemCount: engineers.length,
              itemBuilder: (context, index) {
                Engineer engineer = engineers[index];
                print("Access: ${engineer.enableAccess}");

                // Define row color based on engineer's enableAccess status
                Color rowColor;
                if (engineer.enableAccess == 1) {
                  rowColor = Color(0xFFFAFCFE);  // Light color for disabled access (e.g., pale blue)
                } else if (engineer.enableAccess == 2) {
                  rowColor = Color(0xFFF0BE63);  // Yellowish color for enabled access
                } else {
                  rowColor = Color(0xFFACA8B3);  // Grey color for other cases (e.g., unknown or restricted)
                }

                print("Color: $rowColor");

                return Container(
                  color: rowColor,  // Apply the row color conditionally
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First row: Name + Surname + Home Phone (if available)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left: Name + Surname
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${engineer.engineerName} ${engineer.engineerSurname}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            // Right: Home Phone (if available)
                            if (engineer.engineerHomePhone.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.home, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    engineer.engineerHomePhone,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        // Second row: Email + Mobile Phone (if available)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left: Email
                            Expanded(
                              child: Text(
                                engineer.engineerEmail,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            // Right: Mobile Phone (if available)
                            if (engineer.engineerMobilePhone.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    engineer.engineerMobilePhone,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );


          }
        },
      ),
    );
  }
}

