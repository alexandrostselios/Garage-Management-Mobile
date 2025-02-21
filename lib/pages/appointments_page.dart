import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/models/serviceAppointment.dart';

class ServiceAppointmentsPage extends StatefulWidget {
  const ServiceAppointmentsPage({super.key});

  @override
  State<ServiceAppointmentsPage> createState() => _ServiceAppointmentsPageState();
}

class _ServiceAppointmentsPageState extends State<ServiceAppointmentsPage> {
  late Future<List<ServiceAppointment>> serviceAppointments;

  Future<List<ServiceAppointment>> fetchServiceAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetServiceAppointmentsToListLiteral/1/0'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((jsonItem) => ServiceAppointment.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Failed to load service appointments');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateServiceAppointment(ServiceAppointment serviceAppointment, int status) async {
    try {
      final response = await http.put(
        Uri.parse('https://garagewebapi.eu/api/UpdateServiceAppointment/${serviceAppointment.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (serviceAppointment.kilometer != null) 'Kilometer': serviceAppointment.kilometer,
          if (serviceAppointment.serviceAppointmentDate != null) 'ServiceAppointmentDate': serviceAppointment.serviceAppointmentDate.toIso8601String(),
          if (serviceAppointment.serviceAppointmentComments != null) 'ServiceAppointmentComments': serviceAppointment.serviceAppointmentComments,
          if (serviceAppointment.serviceAppointmentStatus != null) 'ServiceAppointmentStatus': status,
        }),
      );

      if (response.statusCode == 200) {
        print("Updated OK");
        _refreshAppointments();
        return;
      } else {
        throw Exception('Failed to update service appointment');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> _refreshAppointments() async {
    setState(() {
      serviceAppointments = fetchServiceAppointments();
    });
  }

  @override
  void initState() {
    super.initState();
    serviceAppointments = fetchServiceAppointments();
  }

  void _showAppointmentDetails(BuildContext context, ServiceAppointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.serviceAppointmentDetails,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(AppLocalizations.of(context)!.serviceAppointmentID, appointment.id.toString(), null),
              _buildDetailRow(AppLocalizations.of(context)!.customerID, appointment.customerID.toString(), null),
              _buildDetailRow(AppLocalizations.of(context)!.serviceAppointmentStatus, _getServiceAppointmentStatus(appointment.serviceAppointmentStatus), null),
              _buildDetailRow(AppLocalizations.of(context)!.serviceAppointmentKilometer, null, appointment.kilometer),
              _buildDetailRow(AppLocalizations.of(context)!.serviceAppointmentComments, appointment.serviceAppointmentComments, null),
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

  Widget _buildDetailRow(String label, String? value, int? kilometer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            TextSpan(
              text: value ?? (kilometer != null ? '$kilometer' : '-'),
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _getServiceAppointmentStatus(int access) {
    if (access == 1) return AppLocalizations.of(context)!.serviceAppointmentPending;
    if (access == 2) return AppLocalizations.of(context)!.serviceAppointmentCancelled;
    return AppLocalizations.of(context)!.serviceAppointmentCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appointments),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAppointments,
        child: FutureBuilder<List<ServiceAppointment>>(
          future: serviceAppointments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No service appointments found'));
            } else {
              List<ServiceAppointment> appointments = snapshot.data!;
              return ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  ServiceAppointment appointment = appointments[index];

                  Color rowColor;
                  if (appointment.serviceAppointmentStatus == 1) {
                    rowColor = Color(0xFFFAFCFE); // Default color
                  } else if (appointment.serviceAppointmentStatus == 2) {
                    rowColor = Color(0xFFF0BE63); // Pending status
                  } else {
                    rowColor = Color(0xFF4CAF50); // Completed/Canceled status
                  }

                  return Dismissible(
                    key: Key(appointment.id.toString()),
                    direction: appointment.serviceAppointmentStatus == 3
                        ? DismissDirection.none // Disable swipe if status == 3
                        : DismissDirection.horizontal, // Only allow left-to-right swipe for status == 1
                    background: Container(
                      color: appointment.serviceAppointmentStatus == 2 ? Colors.grey : Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: appointment.serviceAppointmentStatus == 2 ? Icon(Icons.pending_actions, color: Colors.white) : Icon(Icons.cancel, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.schedule, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        updateServiceAppointment(appointment,3);
                        //print("Completed"); // Handle scheduled action
                      } else if (direction == DismissDirection.startToEnd) {
                        if(appointment.serviceAppointmentStatus == 2){
                          updateServiceAppointment(appointment,1);
                          //print("Scheduled");
                        }else{
                          updateServiceAppointment(appointment,2);
                          //print("Cancelled");
                        }
                      }
                      return false;
                    },
                    child: Container(
                      color: rowColor,
                      child: ListTile(
                        title: Text('${appointment.customer}', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${appointment.manufacturerName} ${appointment.modelName} (${appointment.licencePlate})',
                        ),
                        onTap: () => _showAppointmentDetails(context, appointment),
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