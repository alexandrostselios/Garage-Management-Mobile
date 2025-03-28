enum AccessStatus {
  enable,
  restricted,
  disabled,
}

enum UserType {
  admin,
  customer,
  engineer,
  employee,
  guest
}

extension AccessStatusExtension on AccessStatus {
  int get value {
    switch (this) {
      case AccessStatus.enable:
        return 1;
      case AccessStatus.restricted:
        return 2;
      case AccessStatus.disabled:
        return 3;
    }
  }

  static AccessStatus fromValue(int value) {
    return AccessStatus.values.firstWhere(
          (status) => status.value == value,
      orElse: () => AccessStatus.disabled, // Default value
    );
  }
}

extension UserTypeExtension on UserType {
  int get value {
    switch (this) {
      case UserType.admin:
        return 1;
      case UserType.customer:
        return 2;
      case UserType.engineer:
        return 3;
      case UserType.employee:
        return 4;
      case UserType.guest:
        return 5;
    }
  }

  static UserType fromValue(int value) {
    return UserType.values.firstWhere(
          (status) => status.value == value,
      orElse: () => UserType.guest, // Default value
    );
  }
}