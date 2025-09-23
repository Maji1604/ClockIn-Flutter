import 'package:equatable/equatable.dart';

/// User entity - core business model
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    this.role,
    this.department,
    this.isActive = true,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String? role;
  final String? department;
  final bool isActive;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    profilePicture,
    role,
    department,
    isActive,
  ];

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? role,
    String? department,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
    );
  }
}
