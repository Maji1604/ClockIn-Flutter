import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/login_request.dart';
import '../entities/login_response.dart';
import '../entities/password_change_request.dart';
import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login user
  Future<Either<Failure, LoginResponse>> login(LoginRequest request);

  /// Change password
  Future<Either<Failure, void>> changePassword(
    String userId,
    PasswordChangeRequest request,
  );

  /// Get current user
  Future<Either<Failure, User>> getCurrentUser();

  /// Logout user
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get stored token
  Future<String?> getToken();

  /// Store token
  Future<void> storeToken(String token);

  /// Clear stored data
  Future<void> clearStoredData();

  /// Store user data
  Future<void> storeUser(User user);

  /// Get stored user
  Future<User?> getStoredUser();
}