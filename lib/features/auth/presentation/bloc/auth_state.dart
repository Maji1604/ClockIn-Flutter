import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/company_membership.dart';

/// Authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final User user;
  final bool requiresPasswordChange;

  const AuthAuthenticated({
    required this.user,
    required this.requiresPasswordChange,
  });

  @override
  List<Object?> get props => [user, requiresPasswordChange];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Password change success state
class AuthPasswordChangeSuccess extends AuthState {
  const AuthPasswordChangeSuccess();
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State representing that the user must pick a company membership
class AuthRequiresCompanySelection extends AuthState {
  final List<CompanyMembership> memberships;

  const AuthRequiresCompanySelection({required this.memberships});

  @override
  List<Object?> get props => [memberships];
}
