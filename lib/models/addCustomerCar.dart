class AddCustomerCar {
  final int id;
  final int customerID;
  final String manufacturerName;
  final String modelName;
  final int modelYear;
  final String licencePlate;
  final String vin;
  final int color;
  final int kilometer;
  final int fuelType;
  final String carImage;
  final int garageID;

  AddCustomerCar({
    required this.id,
    required this.customerID,
    required this.manufacturerName,
    required this.modelName,
    required this.modelYear,
    required this.licencePlate,
    required this.vin,
    required this.color,
    required this.kilometer,
    required this.fuelType,
    required this.carImage,
    required this.garageID
  });

  // Factory method to create a Customer instance from a map (parsed JSON)
  factory AddCustomerCar.fromJson(Map<String, dynamic> json) {
    return AddCustomerCar(
      id: json['id'] ?? 0, // Default to 0 if 'ID' is null
      customerID: json['customerID'] ?? 0, // Default to 0 if 'customerID' is null
      manufacturerName: json['manufacturerName'] ?? '', // Default to 0 if 'manufacturerName' is null
      modelName: json['modelName'] ?? '', // Default to 0 if 'modelName' is null
      modelYear: json['modelYear'] ?? 0, // Default to 0 if 'modelYear' is null
      licencePlate: json['licencePlate'] ?? '', // Default to 0 if 'licencePlate' is null
      vin: json['vin'] ?? '', // Default to 0 if 'vin' is null
      color: json['color'] ?? 0, // Default to 0 if 'color' is null
      kilometer: json['kilometer'] ?? 0, // Default to 0 if 'kilometer' is null
      fuelType: json['fuelType'] ?? 0, // Default to 0 if 'fuelType' is null
      carImage: json['carImage'] ?? '', // Default to 0 if 'fuelType' is null
      garageID: json['garageID'] ?? 0, // Default to 0 if 'kilometer' is null
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'AddCustomerCar {id: $id, customerID: $customerID, manufacturer: $manufacturerName, model: $modelName, year: $modelYear, licence plate: $licencePlate, kilometer: $kilometer, vin: $vin, color: $color, fuelType: $fuelType}';
  }
}
