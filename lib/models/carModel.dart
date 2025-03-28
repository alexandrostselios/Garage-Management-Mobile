class CarModel {
  final int id;
  final String modelName;
  final int garageID;

  CarModel({required this.id, required this.modelName, required this.garageID});

  // Factory method to create a CarModel instance from a map (parsed JSON)
  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      modelName: json['modelName'],
      garageID: json['garageID'],
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'CarModel{id: $id, description: $modelName, garageID: $garageID}';
  }
}
