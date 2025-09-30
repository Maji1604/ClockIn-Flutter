import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/core.dart';
import '../models/user_model.dart';

/// Local data source for authentication operations
abstract class AuthLocalDataSource {
  /// Store authentication token
  Future<void> storeToken(String token);

  /// Get stored token
  Future<String?> getToken();

  /// Store user data
  Future<void> storeUser(UserModel user);

  /// Get stored user
  Future<UserModel?> getStoredUser();

  /// Clear all stored data
  Future<void> clearStoredData();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}

/// Implementation of authentication local data source
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  const AuthLocalDataSourceImpl({required this.sharedPreferences});

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  @override
  Future<void> storeToken(String token) async {
    try {
      AppLogger.debug('Storing authentication token', 'AUTH_LOCAL');
      await sharedPreferences.setString(_tokenKey, token);
    } catch (e) {
      AppLogger.error('Failed to store token: $e', 'AUTH_LOCAL', e);
      throw CacheException(message: 'Failed to store token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      AppLogger.debug('Retrieving authentication token', 'AUTH_LOCAL');
      return sharedPreferences.getString(_tokenKey);
    } catch (e) {
      AppLogger.error('Failed to get token: $e', 'AUTH_LOCAL', e);
      throw CacheException(message: 'Failed to get token: $e');
    }
  }

  @override
  Future<void> storeUser(UserModel user) async {
    try {
      AppLogger.debug('Storing user data: ${user.email}', 'AUTH_LOCAL');
      final userJson = jsonEncode(user.toJson());
      await sharedPreferences.setString(_userKey, userJson);
    } catch (e) {
      AppLogger.error('Failed to store user: $e', 'AUTH_LOCAL', e);
      throw CacheException(message: 'Failed to store user: $e');
    }
  }

  @override
  Future<UserModel?> getStoredUser() async {
    try {
      AppLogger.debug('Retrieving stored user data', 'AUTH_LOCAL');
      final userJson = sharedPreferences.getString(_userKey);
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Failed to get stored user: $e', 'AUTH_LOCAL', e);
      throw CacheException(message: 'Failed to get stored user: $e');
    }
  }

  @override
  Future<void> clearStoredData() async {
    try {
      AppLogger.info('Clearing stored authentication data', 'AUTH_LOCAL');
      await Future.wait([
        sharedPreferences.remove(_tokenKey),
        sharedPreferences.remove(_userKey),
      ]);
    } catch (e) {
      AppLogger.error('Failed to clear stored data: $e', 'AUTH_LOCAL', e);
      throw CacheException(message: 'Failed to clear stored data: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      final user = await getStoredUser();
      
      final isAuth = token != null && user != null;
      AppLogger.debug('Authentication status: $isAuth', 'AUTH_LOCAL');
      
      return isAuth;
    } catch (e) {
      AppLogger.error('Failed to check authentication status: $e', 'AUTH_LOCAL', e);
      return false;
    }
  }
}