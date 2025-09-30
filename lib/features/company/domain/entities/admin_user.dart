import 'package:equatable/equatable.dart';

/// Admin user entity for company registration
class AdminUser extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool mustChangePassword;

  const AdminUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.mustChangePassword,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        role,
        mustChangePassword,
      ];

  @override
  String toString() {
    return 'AdminUser(id: $id, email: $email, name: $fullName)';
  }
}