import 'package:equatable/equatable.dart';
import 'user.dart';
import 'company_membership.dart';

/// Login response entity
///
/// The backend can return either:
/// - a token + user (single-membership or company auto-selected), or
/// - a list of memberships (user belongs to multiple companies) and no token,
///   in which case the client must prompt the user to pick a company and
///   re-submit the login with a company identifier.
class LoginResponse extends Equatable {
  final User user;
  final String? token; // nullable - may be absent when memberships are returned
  final bool requiresPasswordChange;
  final List<CompanyMembership>? memberships;

  const LoginResponse({
    required this.user,
    this.token,
    required this.requiresPasswordChange,
    this.memberships,
  });

  @override
  List<Object?> get props => [user, token, requiresPasswordChange, memberships];
}
