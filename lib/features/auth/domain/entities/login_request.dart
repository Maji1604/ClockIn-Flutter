import 'package:equatable/equatable.dart';

/// Login request entity
class LoginRequest extends Equatable {
  final String email;
  final String password;
  final String? companySlug; // Optional - for company-specific login

  const LoginRequest({
    required this.email,
    required this.password,
    this.companySlug, // Optional
  });

  @override
  List<Object?> get props => [email, password, companySlug];
}