import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String role;
  final String? employeeId;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.employeeId,
  });

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    if (type == 'admin') {
      return UserModel(
        id: json['email'] as String,
        name: json['email'] as String,
        role: 'admin',
        employeeId: null,
      );
    } else {
      // employee
      return UserModel(
        id: json['empId'] as String,
        name: json['name'] as String,
        role: 'employee',
        employeeId: json['empId'] as String,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'role': role, 'employee_id': employeeId};
  }

  @override
  List<Object?> get props => [id, name, role, employeeId];
}
