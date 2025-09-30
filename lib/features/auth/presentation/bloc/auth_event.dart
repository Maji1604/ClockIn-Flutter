import 'package:equatable/equatable.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/entities/password_change_request.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login requested
class AuthLoginRequested extends AuthEvent {
  final LoginRequest request;

  const AuthLoginRequested({required this.request});

  @override
  List<Object?> get props => [request];
}

/// Password change requested
class AuthPasswordChangeRequested extends AuthEvent {
  final String userId;
  final PasswordChangeRequest request;

  const AuthPasswordChangeRequested({
    required this.userId,
    required this.request,
  });

  @override
  List<Object?> get props => [userId, request];
}

/// Logout requested
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Get current user requested
class AuthGetCurrentUserRequested extends AuthEvent {
  const AuthGetCurrentUserRequested();
}