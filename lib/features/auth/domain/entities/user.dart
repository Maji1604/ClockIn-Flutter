import 'package:equatable/equatable.dart';

/// User entity representing authenticated user
class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? companyId;
  final String? companySlug;
  final bool mustChangePassword;
  final bool isFirstLogin;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.companyId,
    this.companySlug,
    required this.mustChangePassword,
    required this.isFirstLogin,
  });

  /// Check if user is admin
  bool get isAdmin => role == 'admin' || role == 'super_admin';

  /// Check if user is employee
  bool get isEmployee => role == 'employee';

  /// Get full name
  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        role,
        companyId,
        companySlug,
        mustChangePassword,
        isFirstLogin,
      ];
}