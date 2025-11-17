import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? createdAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'created_at': createdAt};
  }

  @override
  List<Object?> get props => [id, name, email, createdAt];
}
