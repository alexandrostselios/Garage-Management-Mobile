class CarEnginetype {
  final int id;
  final String fuelType;
  final int garageID;

  CarEnginetype({required this.id, required this.fuelType, required this.garageID});

  // Factory method to create a CarModel instance from a map (parsed JSON)
  factory CarEnginetype.fromJson(Map<String, dynamic> json) {
    return CarEnginetype(
      id: json['id'],
      fuelType: json['fuelType'],
      garageID: json['garageID'],
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'CarModel{id: $id, description: $fuelType, garageID: $garageID}';
  }
}
