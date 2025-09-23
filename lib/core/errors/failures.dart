import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code});
  
  final String message;
  final String? code;
  
  @override
  List<Object?> get props => [message, code];
}

/// Server failure - when API calls fail
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Cache failure - when local storage operations fail
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Network failure - when network connection fails
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

/// Validation failure - when input validation fails
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Authentication failure - when auth operations fail
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
}