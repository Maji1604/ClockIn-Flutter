import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/utils/app_logger.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      AppLogger.info('=== AUTH DATA SOURCE: login ===');
      AppLogger.debug('Base URL: $baseUrl');
      AppLogger.debug('Request URL: $baseUrl/api/auth/login');
      AppLogger.debug('Username: $username');

      final response = await client.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': username, 'password': password}),
      );

      AppLogger.debug('Response status: ${response.statusCode}');
      AppLogger.debug('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          AppLogger.info('Login successful');
          return LoginResponseModel.fromJson(data);
        } else {
          final errorMessage = data['message'] ?? 'Login failed';
          AppLogger.error('Login failed: $errorMessage');
          throw Exception(errorMessage);
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Login failed';
          AppLogger.error(
            'Login failed with status ${response.statusCode}: $errorMessage',
          );
          throw Exception(errorMessage);
        } catch (e) {
          AppLogger.error(
            'Login failed with status ${response.statusCode}, could not parse error: ${response.body}',
          );
          throw Exception('Login failed with status ${response.statusCode}');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Exception during login', e, stackTrace);
      rethrow;
    }
  }
}
