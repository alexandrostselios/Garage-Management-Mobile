class Engineer {
  final int id;
  final String engineerSurname;
  final String engineerName;
  final String engineerEmail;
  final String engineerMobilePhone;
  final String engineerHomePhone;
  final int enableAccess;
  final int garageID;

  Engineer({required this.id, required this.engineerSurname, required this.engineerName, required this.engineerEmail, required this.engineerMobilePhone, required this.engineerHomePhone, required this.enableAccess, required this.garageID});

// Factory method to create a Customer instance from a map (parsed JSON)
  factory Engineer.fromJson(Map<String, dynamic> json) {
    return Engineer(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      engineerSurname: json['engineerSurname'] ?? '', // Default to empty string if 'engineerSurname' is null
      engineerName: json['engineerName'] ?? '', // Default to empty string if 'engineerName' is null
      engineerEmail: json['engineerEmail'] ?? '', // Default to empty string if 'engineerEmail' is null
      engineerMobilePhone: json['engineerMobilePhone'] ?? '', // Default to empty string if 'engineerMobilePhone' is null
      engineerHomePhone: json['engineerHomePhone'] ?? '', // Default to empty string if 'engineerMobilePhone' is null
      enableAccess: json['enableAccess'] ?? 0, // Default to 0 if 'enableAccess' is null
      garageID: json['garageID'] ?? 0, // Default to 0 if 'garageID' is null
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'Engineer{id: $id, surname: $engineerSurname, name: $engineerName, email: $engineerEmail, mobile: $engineerMobilePhone, home: $engineerHomePhone, access: $enableAccess, garageID: $garageID}';
  }
}
