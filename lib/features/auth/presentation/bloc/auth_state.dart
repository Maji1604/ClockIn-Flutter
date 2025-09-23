import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when auth status is unknown
class AuthInitial extends AuthState {}

/// State when authentication check is in progress
class AuthLoading extends AuthState {}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {}

/// State when authentication operation fails
class AuthFailure extends AuthState {
  const AuthFailure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// State when login is in progress
class AuthLoginLoading extends AuthState {}

/// State when login is successful
class AuthLoginSuccess extends AuthState {
  const AuthLoginSuccess({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// State when registration is in progress
class AuthRegisterLoading extends AuthState {}

/// State when registration is successful
class AuthRegisterSuccess extends AuthState {
  const AuthRegisterSuccess({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// State when password reset is in progress
class AuthPasswordResetLoading extends AuthState {}

/// State when password reset is successful
class AuthPasswordResetSuccess extends AuthState {}

/// State when password change is in progress
class AuthPasswordChangeLoading extends AuthState {}

/// State when password change is successful
class AuthPasswordChangeSuccess extends AuthState {}