import '../../domain/entities/user.dart';

/// Remote data source contract for authentication
abstract class AuthRemoteDataSource {
  /// Login user with email and password
  Future<User> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Refresh authentication token
  Future<String> refreshToken();

  /// Reset password
  Future<void> resetPassword({
    required String email,
  });

  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}