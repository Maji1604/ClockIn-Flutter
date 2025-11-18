import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String empId;
  final String name;
  final String? email;
  final String? companyEmail;
  final String? mobileNumber;
  final String? address;
  final String department;
  final String? designation;
  final DateTime createdAt;

  const Profile({
    required this.empId,
    required this.name,
    this.email,
    this.companyEmail,
    this.mobileNumber,
    this.address,
    required this.department,
    this.designation,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    empId,
    name,
    email,
    companyEmail,
    mobileNumber,
    address,
    department,
    designation,
    createdAt,
  ];
}
