import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garage_management/models/engineer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/models/employee.dart'; // Import the Customer model

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late Future<List<Employee>> employees;

  // Fetch the customers from the API
  Future<List<Employee>> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetEmployeesToList/1'), // Pass the appropriate garageID if needed
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Employee Status OK");
        // If the server returns a successful response (200), parse the response
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((jsonItem) => Employee.fromJson(jsonItem)).toList();
      } else {
        // If the server doesn't return a successful response, throw an exception
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      print("Error fetching employees: $e");
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    employees = fetchCustomers(); // Fetch customers when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.employees),
      ),
      body: FutureBuilder<List<Employee>>(
        future: employees,
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
            List<Employee> employees = snapshot.data!;

            return ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                Employee employee = employees[index];
                return ListTile(
                  title: Text('${employee.employeeName} ${employee.employeeSurname}'),
                  subtitle: Text(employee.employeeEmail),
                  trailing: Text('Garage ID: ${employee.garageID}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

