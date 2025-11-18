import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();
  Future<bool> isTokenExpired();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveToken(String token) async {
    print('DEBUG: Saving token to secure storage...');
    await secureStorage.write(key: 'auth_token', value: token);
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    print('DEBUG: Saving timestamp: $timestamp');
    // Save timestamp when token is saved
    await secureStorage.write(key: 'auth_token_timestamp', value: timestamp);
    print('DEBUG: Token and timestamp saved successfully');
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'auth_token_timestamp');
  }

  @override
  Future<void> saveUser(UserModel user) async {
    print('DEBUG: Saving user to secure storage: ${user.name}');
    final userData = jsonEncode(user.toJson());
    await secureStorage.write(key: 'user_data', value: userData);
    print('DEBUG: User saved successfully');
  }

  @override
  Future<UserModel?> getUser() async {
    print('DEBUG: Getting user from secure storage...');
    final userData = await secureStorage.read(key: 'user_data');
    print('DEBUG: User data retrieved: ${userData != null ? "YES" : "NO"}');
    if (userData != null) {
      final user = UserModel.fromJson(jsonDecode(userData));
      print('DEBUG: User parsed: ${user.name}');
      return user;
    }
    print('DEBUG: No user data found');
    return null;
  }

  @override
  Future<void> deleteUser() async {
    await secureStorage.delete(key: 'user_data');
  }

  @override
  Future<bool> isTokenExpired() async {
    print('DEBUG: Checking if token is expired...');
    final timestampStr = await secureStorage.read(key: 'auth_token_timestamp');
    print('DEBUG: Timestamp retrieved: $timestampStr');
    if (timestampStr == null) {
      print('DEBUG: No timestamp found - token expired');
      return true; // No timestamp means expired/invalid
    }

    try {
      final timestamp = int.parse(timestampStr);
      final tokenDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(tokenDate);
      print('DEBUG: Token age: ${difference.inDays} days');

      // Token expires after 7 days
      final expired = difference.inDays >= 7;
      print('DEBUG: Token expired: $expired');
      return expired;
    } catch (e) {
      print('DEBUG: Error parsing timestamp: $e');
      return true; // If parsing fails, consider it expired
    }
  }
}
