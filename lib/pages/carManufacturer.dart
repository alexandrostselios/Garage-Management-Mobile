class CarManufacturer {
  final int id;
  final String manufacturerName;
  final int garageID;

  CarManufacturer({required this.id, required this.manufacturerName, required this.garageID});

  // Factory method to create a CarManufacturer instance from a map (parsed JSON)
  factory CarManufacturer.fromJson(Map<String, dynamic> json) {
    return CarManufacturer(
      id: json['id'],
      manufacturerName: json['manufacturerName'],
      garageID: json['garageID'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CarManufacturer &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'CarManufacturer{id: $id, manufacturerName: $manufacturerName, garageID: $garageID}';
  }
}