class CustomerCar {
  final int id;
  final int customerID;
  final String manufacturerName;
  final String modelName;
  final String modelYear;
  final String licencePlate;
  final String vin;
  final int color;
  final int kilometer;
  final String fuelType;
  final int garageID;

  CustomerCar({
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
    required this.garageID
  });

  // Factory method to create a Customer instance from a map (parsed JSON)
  factory CustomerCar.fromJson(Map<String, dynamic> json) {
    return CustomerCar(
      id: json['id'] ?? 0, // Default to 0 if 'ID' is null
      customerID: json['customerID'] ?? 0, // Default to 0 if 'customerID' is null
      manufacturerName: json['manufacturerName'] ?? '', // Default to 0 if 'manufacturerName' is null
      modelName: json['modelName'] ?? '', // Default to 0 if 'modelName' is null
      modelYear: json['modelYear'] ?? '', // Default to 0 if 'modelYear' is null
      licencePlate: json['licencePlate'] ?? '', // Default to 0 if 'licencePlate' is null
      vin: json['vin'] ?? '', // Default to 0 if 'vin' is null
      color: json['color'] ?? 0, // Default to 0 if 'color' is null
      kilometer: json['kilometer'] ?? 0, // Default to 0 if 'kilometer' is null
      fuelType: json['fuelType'] ?? '', // Default to 0 if 'fuelType' is null
      garageID: json['garageID'] ?? 0, // Default to 0 if 'kilometer' is null
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'Customer Car {id: $id, customerID: $customerID, manufacturer: $manufacturerName, model: $modelName, year: $modelYear, licence plate: $licencePlate, kilometer: $kilometer, vin: $vin, color: $color, fuelType: $fuelType}';
  }
}
