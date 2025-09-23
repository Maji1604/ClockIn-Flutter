import '../models/user_model.dart';

/// Local data source contract for authentication
abstract class AuthLocalDataSource {
  /// Cache user data locally
  Future<void> cacheUser(UserModel user);

  /// Get cached user data
  Future<UserModel?> getCachedUser();

  /// Clear cached user data
  Future<void> clearCache();

  /// Cache authentication token
  Future<void> cacheToken(String token);

  /// Get cached authentication token
  Future<String?> getCachedToken();

  /// Cache refresh token
  Future<void> cacheRefreshToken(String refreshToken);

  /// Get cached refresh token
  Future<String?> getCachedRefreshToken();

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated();
}