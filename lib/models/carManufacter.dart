class Carmanufacter {
  final int id;
  final String manufacturerName;
  final int garageID;

  Carmanufacter({required this.id, required this.manufacturerName, required this.garageID});

  // Factory method to create a CarModel instance from a map (parsed JSON)
  factory Carmanufacter.fromJson(Map<String, dynamic> json) {
    return Carmanufacter(
      id: json['id'],
      manufacturerName: json['manufacturerName'],
      garageID: json['garageID'],
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'CarModel{id: $id, description: $manufacturerName, garageID: $garageID}';
  }
}
