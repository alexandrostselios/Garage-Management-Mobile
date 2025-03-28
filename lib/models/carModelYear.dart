class CarModelYear {
  final int id;
  final String description;
  final int garageID;

  CarModelYear({required this.id, required this.description, required this.garageID});

  // Factory method to create a CarManufacturer instance from a map (parsed JSON)
  factory CarModelYear.fromJson(Map<String, dynamic> json) {
    return CarModelYear(
      id: json['id'],
      description: json['description'],
      garageID: json['garageID'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CarModelYear &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'CarModelYear{id: $id, manufacturerName: $description, garageID: $garageID}';
  }
}