class ServiceAppointment {
  final int id;
  final String customer;
  final int customerID;
  final int customerCarID;
  final String manufacturerName;
  final String modelName;
  final String licencePlate;
  final String vin;
  final int color;
  final int garageID;
  final String serviceAppointmentComments;
  final int serviceAppointmentStatus;
  final int kilometer;
  final DateTime serviceAppointmentDate;

  ServiceAppointment({required this.id, required this.customer, required this.customerID, required this.customerCarID, required this.color, required this.manufacturerName, required this.modelName, required this.licencePlate, required this.vin, required this.serviceAppointmentComments, required this.serviceAppointmentStatus, required this.serviceAppointmentDate, required this.kilometer, required this.garageID});

// Factory method to create a Customer instance from a map (parsed JSON)
  factory ServiceAppointment.fromJson(Map<String, dynamic> json) {
    return ServiceAppointment(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      customerID: json['customerID'] ?? 0, // Default to 0 if 'customerID' is null
      customer: json['customer'] ?? '', // Default to 0 if 'customer' is null
      customerCarID: json['customerCarID'] ?? 0, // Default to 0 if 'customerCarID' is null
      serviceAppointmentComments: json['serviceAppointmentComments'] ?? '', // Default to 0 if 'serviceAppointmentComments' is null
      serviceAppointmentStatus: json['serviceAppointmentStatus'] ?? 0, // Default to 0 if 'serviceAppointmentStatus' is null
      kilometer: json['kilometer'] ?? 0, // Default to 0 if 'garageID' is null
      color: json['color'] ?? 0, // Default to 0 if 'color' is null
      serviceAppointmentDate: json['serviceAppointmentDate'] != null
          ? DateTime.parse(json['serviceAppointmentDate']) // ✅ Convert String to DateTime
          : DateTime.now(), // Default value if null
      garageID: json['garageID'] ?? 0,
      manufacturerName: json['manufacturerName'] ?? '',
      modelName: json['modelName'] ?? '',
      licencePlate: json['licencePlate'] ?? '',
      vin: json['vin'] ?? '', // Default to 0 if 'garageID' is null
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'ServiceAppointment{id: $id, garageID: $garageID}';
  }
}