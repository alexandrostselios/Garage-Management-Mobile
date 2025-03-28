import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garage_management/enums.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/models/customer.dart';

import '../models/customerCar.dart';
import 'customerCars_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late Future<List<Customer>> customers;

  Future<List<Customer>> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetCustomersToList/1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((jsonItem) => Customer.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<List<CustomerCar>> fetchCustomerCars(int customerID) async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetCustomerCarsByCustomerID/1/$customerID'),
        headers: {'Content-Type': 'application/json'},
      );

      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((jsonItem) => CustomerCar.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Failed to load customer cars');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> _refreshCustomers() async {
    setState(() {
      customers = fetchCustomers();
    });
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      final Map<String, dynamic> requestBody = {
        if (customer.customerID != null) 'CustomerID': customer.customerID,
        if (customer.customerSurname != null) 'CustomerSurname': customer.customerSurname,
        if (customer.customerName != null) 'CustomerName': customer.customerName,
        if (customer.customerEmail != null) 'CustomerEmail': customer.customerEmail,
        if (customer.customerHomePhone != null) 'CustomerHomePhone': customer.customerHomePhone,
        if (customer.modifiedDate != null) 'ModifiedDate': customer.modifiedDate!.toIso8601String(), // Convert DateTime to string
        if (customer.garageID != null) 'GarageID': customer.garageID,
        if (customer.enableAccess != null) 'EnableAccess': customer.enableAccess,
      };

      // Debugging: Print the request body to the console
      print("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.put(
        Uri.parse('https://garagewebapi.eu/api/UpdateCustomer/${customer.customerID}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _refreshCustomers();
        return;
      } else {
        throw Exception('Failed to update customer with error code ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    customers = fetchCustomers();
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
              // TODO: Implement actual email sending logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.emailSentTo +" $email")),
              );
            },
            child: Text(AppLocalizations.of(context)!.send),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.customerDetails,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(AppLocalizations.of(context)!.customerID, customer.customerID.toString()),
              _buildDetailRow(AppLocalizations.of(context)!.surname, customer.customerSurname),
              _buildDetailRow(AppLocalizations.of(context)!.name, customer.customerName),
              _buildDetailRow(AppLocalizations.of(context)!.customerComments, customer.customerComment),
              _buildDetailRow(AppLocalizations.of(context)!.enableAccess, _getAccessStatus(customer.enableAccess)),
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
  }

  void _showCustomerCars(BuildContext context, Customer customer) async {
    try {
      List<CustomerCar> customerCars = await fetchCustomerCars(customer.customerID);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerCarsPage(customer: customer, customerCars: customerCars),
        ),
      );
    } catch (e) {
      print("Error fetching customer cars: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load customer cars")),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  void _showCustomerEditPopup(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController(text: customer.customerName);
        TextEditingController surnameController = TextEditingController(text: customer.customerSurname);
        TextEditingController mobilePhoneController = TextEditingController(text: customer.customerMobilePhone);
        TextEditingController homePhoneeController = TextEditingController(text: customer.customerHomePhone);
        TextEditingController commentsController = TextEditingController(text: customer.customerComment);

        // Define the status options and their integer values
        List<Map<String, dynamic>> statusOptions = [
          {'label': AppLocalizations.of(context)!.enableAccess, 'value': 1},
          {'label': AppLocalizations.of(context)!.restrictedAccess, 'value': 2},
          {'label': AppLocalizations.of(context)!.disabledAccess, 'value': 3},
        ];

        // Set the initial selected status based on the customer's status
        int selectedStatus = customer.enableAccess; // assuming customer.enableAccess is an integer

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.editCustomer),
              content: SingleChildScrollView(
                child: IntrinsicHeight(
                  child: Column(
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
                      TextField(
                        controller: mobilePhoneController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.mobilePhone),
                      ),
                      TextField(
                        controller: homePhoneeController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.homePhone),
                      ),
                      TextField(
                        controller: commentsController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.customerComments),
                      ),
                      DropdownButton<int>(
                        value: selectedStatus,
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                          });
                        },
                        items: statusOptions.map<DropdownMenuItem<int>>((Map<String, dynamic> status) {
                          return DropdownMenuItem<int>(
                            value: status['value'],
                            child: Text(
                              status['label'],
                              style: TextStyle(
                                color: status['value'] == selectedStatus ? Colors.blue : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Keeps buttons in the same row
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center items inside button
                          children: [
                            Icon(Icons.cancel, color: Colors.red),
                            SizedBox(width: 5),
                            Text(AppLocalizations.of(context)!.cancel),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between buttons
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          String updatedName = nameController.text;
                          String updatedSurname = surnameController.text;
                          String updatedMobilePhone = mobilePhoneController.text;
                          String updatedHomePhone = homePhoneeController.text;
                          String updatedComments = commentsController.text;

                          Customer updatedCustomer = Customer(
                            customerID: customer.customerID,
                            customerName: updatedName,
                            customerSurname: updatedSurname,
                            customerEmail: customer.customerEmail,
                            enableAccess: selectedStatus,
                            garageID: customer.garageID,
                            customerHomePhone: updatedHomePhone,
                            customerMobilePhone: updatedMobilePhone,
                            customerComment: updatedComments,
                            modifiedDate: DateTime.now(),
                          );

                          updateCustomer(updatedCustomer);
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center items inside button
                          children: [
                            Icon(Icons.save, color: Colors.green),
                            SizedBox(width: 5),
                            Text(AppLocalizations.of(context)!.save),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customersList),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCustomers,
        child: FutureBuilder<List<Customer>>(
          future: customers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No customers found'));
            } else {
              List<Customer> customers = snapshot.data!;

              return ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  Customer customer = customers[index];

                  AccessStatus accessStatus = AccessStatusExtension.fromValue(customer.enableAccess); //Enum status of customer EnableAccess property
                  Color rowColor = accessStatus == AccessStatus.enable
                      ? Color(0xFFFAFCFE)
                      : (accessStatus == AccessStatus.restricted
                      ? Color(0xFFF0BE63)
                      : Color(0xFFACA8B3));
                  // if (accessStatus == AccessStatus.enable) {
                  //   rowColor = Color(0xFFFAFCFE);
                  // } else if (accessStatus == AccessStatus.restricted) {
                  //   rowColor = Color(0xFFF0BE63);
                  // } else {
                  //   rowColor = Color(0xFFACA8B3);
                  // }

                  return Dismissible(
                    key: Key(customer.customerID.toString()),
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
                        _showSendEmailPopup(context, customer.customerEmail);  // Right Swipe: Show Email Popup
                      } else if (direction == DismissDirection.startToEnd) {
                        _showCustomerEditPopup(context, customer);  // Left Swipe: Show Edit Popup
                      }
                      return false;  // Prevent the item from being dismissed
                    },
                    child: GestureDetector(
                      onDoubleTap: () => _showCustomerDetails(context, customer) ,
                      onTap: () => _showCustomerCars(context, customer),
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
                                      '${customer.customerName} ${customer.customerSurname}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ),
                                  if (customer.customerHomePhone.isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.home, size: 16),
                                        SizedBox(width: 8),
                                        Text(customer.customerHomePhone, style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(customer.customerEmail, style: TextStyle(fontSize: 14)),
                                  ),
                                  if (customer.customerMobilePhone.isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone, size: 16),
                                        SizedBox(width: 8),
                                        Text(customer.customerMobilePhone, style: TextStyle(fontSize: 12)),
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
}
