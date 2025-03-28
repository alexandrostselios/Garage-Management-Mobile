import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garage_management/models/engineer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/models/employee.dart';

import '../enums.dart'; // Import the Employee model

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late Future<List<Employee>> employees;

  // Fetch employees from the API
  Future<List<Employee>> fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetEmployeesToList/1'), // Adjust garageID as needed
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Employee Status OK");
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((jsonItem) => Employee.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      print("Error fetching employees: $e");
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    employees = fetchEmployees();
  }

  // Refresh function for pull-to-refresh
  Future<void> _refreshEmployees() async {
    setState(() {
      employees = fetchEmployees();
    });
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      final Map<String, dynamic> requestBody = {
        if (employee.employeeID != null) 'EmployeeID': employee.employeeID,
        if (employee.employeeSurname != null) 'EmployeeSurname': employee.employeeSurname,
        if (employee.employeeName != null) 'EmployeeName': employee.employeeName,
        if (employee.employeeEmail != null) 'EmployeeEmail': employee.employeeEmail,
        // if (customer.customerHomePhone != null) 'CustomerHomePhone': customer.customerHomePhone,
        // if (customer.modifiedDate != null) 'ModifiedDate': customer.modifiedDate!.toIso8601String(), // Convert DateTime to string
        if (employee.garageID != null) 'GarageID': employee.garageID,
        if (employee.enableAccess != null) 'EnableAccess': employee.enableAccess,
      };

      // Debugging: Print the request body to the console
      print("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.put(
        Uri.parse('https://garagewebapi.eu/api/UpdateEmployee/${employee.employeeID}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _refreshEmployees();
        return;
      } else {
        throw Exception('Failed to update employee with error code ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  void _showEmployeeEditPopup(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController(text: employee.employeeName);
        TextEditingController surnameController = TextEditingController(text: employee.employeeSurname);
        //TextEditingController mobilePhoneController = TextEditingController(text: employee.customerMobilePhone);
        //TextEditingController homePhoneeController = TextEditingController(text: employee.customerHomePhone);

        // Define the status options and their integer values
        List<Map<String, dynamic>> statusOptions = [
          {'label': AppLocalizations.of(context)!.enableAccess, 'value': 1},
          {'label': AppLocalizations.of(context)!.restrictedAccess, 'value': 2},
          {'label': AppLocalizations.of(context)!.disabledAccess, 'value': 3},
        ];

        // Set the initial selected status based on the customer's status
        int selectedStatus = employee.enableAccess; // assuming customer.enableAccess is an integer

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
                      // TextField(
                      //   controller: mobilePhoneController,
                      //   decoration: InputDecoration(labelText: AppLocalizations.of(context)!.mobilePhone),
                      // ),
                      // TextField(
                      //   controller: homePhoneeController,
                      //   decoration: InputDecoration(labelText: AppLocalizations.of(context)!.homePhone),
                      // ),
                      // TextField(
                      //   controller: commentsController,
                      //   decoration: InputDecoration(labelText: AppLocalizations.of(context)!.customerComments),
                      // ),
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
                          //String updatedMobilePhone = mobilePhoneController.text;
                          //String updatedHomePhone = homePhoneeController.text;
                          //String updatedComments = commentsController.text;

                          Employee updatedEmployee = Employee(
                            id: employee.id,
                            employeeID: employee.employeeID,
                            employeeName: updatedName,
                            employeeSurname: updatedSurname,
                            employeeEmail: employee.employeeEmail,
                            enableAccess: selectedStatus,
                            garageID: employee.garageID,
                            modifiedDate: DateTime.now(),
                          );

                          updateEmployee(updatedEmployee);
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
        title: Text(AppLocalizations.of(context)!.employeesList),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEmployees,
        child: FutureBuilder<List<Employee>>(
          future: employees,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No employees found'));
            } else {
              List<Employee> employees = snapshot.data!;

              return ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  Employee employee = employees[index];

                  AccessStatus accessStatus = AccessStatusExtension.fromValue(employee.enableAccess); //Enum status of employee EnableAccess property
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
                      key: Key(employee.employeeID.toString()),
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
                        print("Send email to employee");
                         //_showSendEmailPopup(context, customer.customerEmail);  // Right Swipe: Show Email Popup
                      } else if (direction == DismissDirection.startToEnd) {
                         //print("Edit to employee");
                        _showEmployeeEditPopup(context, employee);  // Left Swipe: Show Edit Popup
                      }
                      return false;  // Prevent the item from being dismissed
                      },
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)!.employeeDetails,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${AppLocalizations.of(context)!.employeeID}: ',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: '${employee.employeeID}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${AppLocalizations.of(context)!.surname}: ',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: '${employee.employeeSurname}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${AppLocalizations.of(context)!.name}: ',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: '${employee.employeeName}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${AppLocalizations.of(context)!.enableAccess}: ',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: employee.enableAccess == 1
                                              ? AppLocalizations.of(context)!.enabledAccess
                                              : employee.enableAccess == 2
                                              ? AppLocalizations.of(context)!.restrictedAccess
                                              : AppLocalizations.of(context)!.disabledAccess,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        color: rowColor,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${employee.employeeName} ${employee.employeeSurname}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    employee.employeeEmail,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
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