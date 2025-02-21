import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garage_management/models/engineer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/models/employee.dart'; // Import the Employee model

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

                  Color rowColor;
                  if (employee.enableAccess == 1) {
                    rowColor = Color(0xFFFAFCFE);
                  } else if (employee.enableAccess == 2) {
                    rowColor = Color(0xFFF0BE63);
                  } else {
                    rowColor = Color(0xFFACA8B3);
                  }

                  return GestureDetector(
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