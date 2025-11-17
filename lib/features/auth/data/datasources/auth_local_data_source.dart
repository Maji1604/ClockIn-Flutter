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
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await secureStorage.write(
      key: 'user_data',
      value: jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final userData = await secureStorage.read(key: 'user_data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  @override
  Future<void> deleteUser() async {
    await secureStorage.delete(key: 'user_data');
  }
}
