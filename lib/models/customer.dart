class Customer {
  final int customerID;
  final String customerSurname;
  final String customerName;
  final String customerEmail;
  final String customerMobilePhone;
  final String customerHomePhone;
  final String customerComment;
  final DateTime? modifiedDate;
  final int enableAccess;
  final int garageID;

  Customer({
    required this.customerID,
    required this.customerSurname,
    required this.customerName,
    required this.customerEmail,
    required this.customerMobilePhone,
    required this.customerHomePhone,
    required this.customerComment,
    required this.modifiedDate,
    required this.enableAccess,
    required this.garageID,
  });

  // Factory method to create a Customer instance from a map (parsed JSON)
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerID: json['customerID'] ?? 0, // Default to 0 if 'customerID' is null
      customerSurname: json['customerSurname'] ?? '', // Default to empty string if 'customerSurname' is null
      customerName: json['customerName'] ?? '', // Default to empty string if 'customerName' is null
      customerEmail: json['customerEmail'] ?? '', // Default to empty string if 'customerEmail' is null
      customerMobilePhone: json['customerMobilePhone'] ?? '', // Default to empty string if 'customerMobilePhone' is null
      customerHomePhone: json['customerHomePhone'] ?? '', // Default to empty string if 'customerHomePhone' is null
      customerComment: json['customerComment'] ?? '', // Default to empty string if 'customerComment' is null
      modifiedDate: json['modifiedDate'] != null
        ? DateTime.parse(json['modifiedDate']) // ✅ Convert String to DateTime
        : null, // Default value if null
      enableAccess: json['enableAccess'] ?? 0, // Default to 0 if 'enableAccess' is null
      garageID: json['garageID'] ?? 0, // Default to 0 if 'garageID' is null
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'Customer{customerID: $customerID, surname: $customerSurname, name: $customerName, email: $customerEmail, mobile: $customerMobilePhone, home:$customerHomePhone, access: $enableAccess, garageID: $garageID}';
  }
}
