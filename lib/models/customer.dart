class Customer {
  final int id;
  final String customerSurname;
  final String customerName;
  final String customerEmail;
  final String customerMobilePhone;
  final String customerHomePhone;
  final int enableAccess;
  final int garageID;

  Customer({
    required this.id,
    required this.customerSurname,
    required this.customerName,
    required this.customerEmail,
    required this.customerMobilePhone,
    required this.customerHomePhone,
    required this.enableAccess,
    required this.garageID,
  });

  // Factory method to create a Customer instance from a map (parsed JSON)
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      customerSurname: json['customerSurname'] ?? '', // Default to empty string if 'customerSurname' is null
      customerName: json['customerName'] ?? '', // Default to empty string if 'customerName' is null
      customerEmail: json['customerEmail'] ?? '', // Default to empty string if 'customerEmail' is null
      customerMobilePhone: json['customerMobilePhone'] ?? '', // Default to empty string if 'customerMobile' is null
      customerHomePhone: json['customerHomePhone'] ?? '', // Default to empty string if 'customerMobile' is null
      enableAccess: json['enableAccess'] ?? 0, // Default to 0 if 'enableAccess' is null
      garageID: json['garageID'] ?? 0, // Default to 0 if 'garageID' is null
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'Customer{id: $id, surname: $customerSurname, name: $customerName, email: $customerEmail, mobile: $customerMobilePhone, home:$customerHomePhone, access: $enableAccess, garageID: $garageID}';
  }
}
