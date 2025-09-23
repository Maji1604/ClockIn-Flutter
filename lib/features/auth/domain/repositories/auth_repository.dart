import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Authentication repository contract
/// Defines the interface for authentication operations
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current user from cache
  Future<Either<Failure, User?>> getCurrentUser();

  /// Refresh authentication token
  Future<Either<Failure, String>> refreshToken();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Reset password
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  /// Change password
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}