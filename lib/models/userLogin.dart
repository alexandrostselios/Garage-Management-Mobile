class UserLogin {
  final String success;
  final int id;
  late final String email;
  late final String surname;
  late final String name;
  late final int userType;
  late final int garageID;

  UserLogin({required this.id, required this.email,required this.surname,required this.name,required this.userType,required this.garageID, required this.success});

  // Factory method to create a CarModel instance from a map (parsed JSON)
  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      success: json['success'],
      id: json['id'],
      email: json['email'],
      name: json['name'],
      surname: json['surname'],
      userType: json['userType'],
      garageID: json['garageID']
    );
  }

  // To make it easier to print the model for debugging
  @override
  String toString() {
    return 'Login: $success';
  }
}