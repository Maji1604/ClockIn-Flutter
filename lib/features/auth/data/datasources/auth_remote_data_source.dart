import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/login_response_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/app_logger.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  String get baseUrl => ApiConfig.baseUrl;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      AppLogger.info('=== AUTH DATA SOURCE: login ===');
      AppLogger.debug('Base URL (primary): $baseUrl');
      AppLogger.debug('Request URL: $baseUrl/api/auth/login');
      AppLogger.debug('Username: $username');
      http.Response response;
      try {
        response = await client.post(
          Uri.parse('$baseUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'identifier': username, 'password': password}),
        );
      } on SocketException catch (se) {
        AppLogger.error(
          'Network/DNS error on primary endpoint',
          se,
          StackTrace.current,
        );
        // Try fallback if configured
        if (ApiConfig.hasFallback && ApiConfig.fallbackBaseUrl != null) {
          final fb = ApiConfig.fallbackBaseUrl!;
          AppLogger.info('Retrying login against fallback base URL: $fb');
          response = await client.post(
            Uri.parse('$fb/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'identifier': username, 'password': password}),
          );
        } else {
          rethrow;
        }
      }

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
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('Network error during login', e, stackTrace);
      throw Exception(
        'Network error: Unable to reach server. Please check your internet connection or try again.',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Exception during login', e, stackTrace);
      rethrow;
    }
  }
}
