import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/models/customer.dart'; // Import the Customer model

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late Future<List<Customer>> customers;

  // Fetch the customers from the API
  Future<List<Customer>> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetCustomersToList/1'), // Pass the appropriate garageID if needed
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Customer Status OK");
        // If the server returns a successful response (200), parse the response
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((jsonItem) => Customer.fromJson(jsonItem)).toList();
      } else {
        // If the server doesn't return a successful response, throw an exception
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      print("Error fetching customers: $e");
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    customers = fetchCustomers(); // Fetch customers when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customers),
      ),
      body: FutureBuilder<List<Customer>>(
        future: customers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while the data is being fetched
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if something went wrong
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if no customers are found
            return Center(child: Text('No customers found'));
          } else {
            // Display the list of customers
            List<Customer> customers = snapshot.data!;

            return ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                Customer customer = customers[index];

                // Color the row based on a condition (example: based on enableAccess or other field)
                Color rowColor;
                if (customer.enableAccess == 1) {
                  rowColor = Color(0xFFFAFCFE);  // Light color for disabled access
                } else if (customer.enableAccess == 2) {
                  rowColor = Color(0xFFF0BE63);  // Yellowish color for enabled access
                } else {
                  rowColor = Color(0xFFACA8B3);  // Grey color for other cases
                }

                return Container(
                  color: rowColor,  // Apply the background color conditionally
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
                                    '${customer.customerName} ${customer.customerSurname}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            // Right: Home Phone (if available)
                            if (customer.customerHomePhone.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.home, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    customer.customerHomePhone,
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
                                customer.customerEmail,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            // Right: Mobile Phone (if available)
                            if (customer.customerMobilePhone.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    customer.customerMobilePhone,
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