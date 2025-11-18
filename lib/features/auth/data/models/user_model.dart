import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String role;
  final String? employeeId;
  final bool requiresPasswordReset;
  final String? email;
  final String? mobileNumber;
  final String? address;
  final String? designation;
  final String? department;
  final String? companyEmail;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.employeeId,
    this.requiresPasswordReset = false,
    this.email,
    this.mobileNumber,
    this.address,
    this.designation,
    this.department,
    this.companyEmail,
  });

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';
  bool get needsOnboarding =>
      requiresPasswordReset ||
      (mobileNumber == null || mobileNumber!.isEmpty) ||
      (address == null || address!.isEmpty);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'type' (from API response) and 'role' (from storage)
    final type = json['type'] as String? ?? json['role'] as String;

    if (type == 'admin') {
      return UserModel(
        id: json['id'] as String? ?? json['email'] as String? ?? 'admin',
        name: json['name'] as String? ?? json['role'] as String? ?? 'Admin',
        role: 'admin',
        employeeId: null,
        email: json['email'] as String?,
      );
    } else {
      // employee
      return UserModel(
        id: json['id'] as String? ?? json['empId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: 'employee',
        employeeId: json['employee_id'] as String? ?? json['empId'] as String?,
        requiresPasswordReset: json['requiresPasswordReset'] as bool? ?? false,
        email: json['email'] as String?,
        mobileNumber: json['mobileNumber'] as String?,
        address: json['address'] as String?,
        designation: json['designation'] as String?,
        department: json['department'] as String?,
        companyEmail: json['companyEmail'] as String?,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'employee_id': employeeId,
      'requiresPasswordReset': requiresPasswordReset,
      'email': email,
      'mobileNumber': mobileNumber,
      'address': address,
      'designation': designation,
      'department': department,
      'companyEmail': companyEmail,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    role,
    employeeId,
    requiresPasswordReset,
    email,
    mobileNumber,
    address,
    designation,
    department,
    companyEmail,
  ];
}
