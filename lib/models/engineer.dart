class Engineer {
  final int id;
  final int engineerID;
  late final String engineerSurname;
  late final String engineerName;
  final String engineerEmail;
  final String engineerMobilePhone;
  final String engineerHomePhone;
  final String engineerComment;
  final DateTime? engineerModifiedDate;
  final String  engineerPhoto;
  final String? engineerPassword;
  final DateTime? lastLoginDate;
  final int enableAccess;
  final int garageID;
  final List<String> engineerSpecialities; // Multi-value field

  Engineer({
    required this.id,
    required this.engineerID,
    required this.engineerSurname,
    required this.engineerName,
    required this.engineerEmail,
    required this.engineerPassword,
    required this.engineerMobilePhone,
    required this.engineerHomePhone,
    required this.engineerComment,
    required this.enableAccess,
    required this.lastLoginDate,
    required this.garageID,
    required this.engineerSpecialities, // Include in constructor
    required this.engineerModifiedDate,
    required this.engineerPhoto, // Add photo URL or base64 string

  });

  factory Engineer.fromJson(Map<String, dynamic> json) {
    return Engineer(
      id: json['id'] ?? 0,
      engineerID: json['engineerID'] ?? 0,
      engineerSurname: json['engineerSurname'] ?? '',
      engineerName: json['engineerName'] ?? '',
      engineerEmail: json['engineerEmail'] ?? '',
      engineerMobilePhone: json['engineerMobilePhone'] ?? '',
      engineerHomePhone: json['engineerHomePhone'] ?? '',
      engineerComment: json['engineerComment'] ?? '',
      enableAccess: json['enableAccess'] ?? 0,
      engineerPassword: json['engineerPassword'] ?? '',
      garageID: json['garageID'] ?? 0,
      engineerPhoto: json['engineerPhoto'] ?? '', // Default to empty string if null
      engineerModifiedDate: json['modifiedDate'] != null
          ? DateTime.parse(json['modifiedDate']) // ✅ Convert String to DateTime
          : null, // Default value if null
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate']) // ✅ Convert String to DateTime
          : null, // Default value if null
      engineerSpecialities: (json['engineerSpecialities'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [], // Convert JSON array to List<String>
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'engineerID': engineerID,
      'engineerSurname': engineerSurname,
      'engineerName': engineerName,
      'engineerEmail': engineerEmail,
      'engineerMobilePhone': engineerMobilePhone,
      'engineerHomePhone': engineerHomePhone,
      'engineerComment': engineerComment,
      'enableAccess': enableAccess,
      'garageID': garageID,
      'engineerSpecialities': engineerSpecialities, // Store as a list
    };
  }
}