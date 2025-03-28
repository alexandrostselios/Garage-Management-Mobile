class Employee {
  final int id;
  final int employeeID;
  final String employeeSurname;
  final String employeeName;
  final String employeeEmail;
  final DateTime? modifiedDate;
  final int enableAccess;
  final int garageID;

  Employee({required this.id, required this.employeeID, required this.employeeSurname, required this.employeeName, required this.employeeEmail, required this.modifiedDate, required this.enableAccess, required this.garageID});

// Factory method to create a Customer instance from a map (parsed JSON)
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      employeeID: json['employeeID'] ?? 0, // Default to 0 if 'employeeID' is null
      employeeSurname: json['employeeSurname'] ?? '', // Default to empty string if 'customerSurname' is null
      employeeName: json['employeeName'] ?? '', // Default to empty string if 'customerName' is null
      employeeEmail: json['employeeEmail'] ?? '', // Default to empty string if 'customerEmail' is null
      modifiedDate: json['modifiedDate'] != null
          ? DateTime.parse(json['modifiedDate']) // ✅ Convert String to DateTime
          : null, // Default value if null
      enableAccess: json['enableAccess'] ?? 0, // Default to 0 if 'garageID' is null
      garageID: json['garageID'] ?? 0, // Default to 0 if 'garageID' is null
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'Engineer{id: $id, surname: $employeeSurname, name: $employeeName, email: $employeeEmail, garageID: $garageID}';
  }
}
