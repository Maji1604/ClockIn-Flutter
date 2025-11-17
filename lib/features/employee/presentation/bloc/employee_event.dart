import 'package:equatable/equatable.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {
  final String token;

  const LoadEmployees(this.token);

  @override
  List<Object?> get props => [token];
}

class AddEmployee extends EmployeeEvent {
  final String token;
  final String name;
  final String email;
  final String password;

  const AddEmployee({
    required this.token,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [token, name, email, password];
}

class DeleteEmployee extends EmployeeEvent {
  final String token;
  final String empId;

  const DeleteEmployee({required this.token, required this.empId});

  @override
  List<Object?> get props => [token, empId];
}
