import 'package:dio/dio.dart';
import '../../../../core/core.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/password_change_request_model.dart';
import '../models/user_model.dart';

/// Remote data source for authentication operations
abstract class AuthRemoteDataSource {
  /// Login user
  Future<LoginResponseModel> login(LoginRequestModel request);

  /// Change password
  Future<void> changePassword(
    String userId,
    PasswordChangeRequestModel request,
  );

  /// Get current user
  Future<UserModel> getCurrentUser();

  /// Logout user
  Future<void> logout();
}

/// Implementation of authentication remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio httpClient;

  const AuthRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      AppLogger.info('Logging in user: ${request.email}', 'AUTH_API');

      // Support both email-only and company-specific login
      final response = await httpClient.post(
        '/api/auth/login',
        data: request.toJson(),
        options: Options(headers: request.getHeaders()),
      );

      if (response.statusCode == 200) {
        AppLogger.info('Login successful', 'AUTH_API');
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Failed to login',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Log full response body for easier debugging
      AppLogger.error(
        'Login failed: ${e.message}. Response: ${e.response?.data}',
        'AUTH_API',
        e,
      );

      if (e.response != null) {
        final data = e.response?.data;
        String errorMessage = 'Login failed';
        try {
          if (data is Map<String, dynamic>) {
            // Common shapes: { message: '...'}, { error: {message: '...', code: '...'} }, { data: { message: '...'} }
            if (data.containsKey('message') &&
                data['message'] is String &&
                (data['message'] as String).isNotEmpty) {
              errorMessage = data['message'];
            } else if (data.containsKey('error') &&
                data['error'] is Map<String, dynamic>) {
              final err = data['error'] as Map<String, dynamic>;
              if (err.containsKey('message') &&
                  err['message'] is String &&
                  (err['message'] as String).isNotEmpty) {
                errorMessage = err['message'];
              } else if (err.containsKey('message') && err['message'] is Map) {
                errorMessage = err['message'].toString();
              }

              if (err.containsKey('code') && err['code'] != null) {
                errorMessage = '$errorMessage (code: ${err['code']})';
              }
            } else if (data.containsKey('data') &&
                data['data'] is Map<String, dynamic> &&
                data['data']['message'] is String) {
              errorMessage = data['data']['message'];
            } else {
              // fallback to stringifying the response body
              errorMessage = data.toString();
            }
          } else if (data is String && data.isNotEmpty) {
            errorMessage = data;
          }
        } catch (_) {
          // ignore parsing errors and keep generic message
        }

        throw ServerException(
          message: errorMessage,
          statusCode: e.response?.statusCode,
        );
      } else {
        throw const NetworkException(message: 'Network error during login');
      }
    } catch (e) {
      AppLogger.error('Unexpected error during login: $e', 'AUTH_API', e);
      throw ServerException(message: 'Unexpected error during login: $e');
    }
  }

  @override
  Future<void> changePassword(
    String userId,
    PasswordChangeRequestModel request,
  ) async {
    try {
      AppLogger.info('Changing password for user: $userId', 'AUTH_API');

      final response = await httpClient.put(
        '/api/users/$userId/password',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        AppLogger.info('Password change successful', 'AUTH_API');
      } else {
        throw ServerException(
          message: 'Failed to change password',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Password change failed: ${e.message}', 'AUTH_API', e);

      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ?? 'Password change failed';
        throw ServerException(
          message: errorMessage,
          statusCode: e.response?.statusCode,
        );
      } else {
        throw const NetworkException(
          message: 'Network error during password change',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Unexpected error during password change: $e',
        'AUTH_API',
        e,
      );
      throw ServerException(
        message: 'Unexpected error during password change: $e',
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      AppLogger.debug('Getting current user', 'AUTH_API');

      final response = await httpClient.get('/api/auth/me');

      if (response.statusCode == 200) {
        AppLogger.debug('Current user retrieved successfully', 'AUTH_API');
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Failed to get current user',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Get current user failed: ${e.message}', 'AUTH_API', e);

      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ?? 'Failed to get user';
        throw ServerException(
          message: errorMessage,
          statusCode: e.response?.statusCode,
        );
      } else {
        throw const NetworkException(message: 'Network error getting user');
      }
    } catch (e) {
      AppLogger.error(
        'Unexpected error getting current user: $e',
        'AUTH_API',
        e,
      );
      throw ServerException(
        message: 'Unexpected error getting current user: $e',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      AppLogger.info('Logging out user', 'AUTH_API');

      final response = await httpClient.post('/api/auth/logout');

      if (response.statusCode == 200) {
        AppLogger.info('Logout successful', 'AUTH_API');
      } else {
        throw ServerException(
          message: 'Failed to logout',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Logout failed: ${e.message}', 'AUTH_API', e);

      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Logout failed';
        throw ServerException(
          message: errorMessage,
          statusCode: e.response?.statusCode,
        );
      } else {
        throw const NetworkException(message: 'Network error during logout');
      }
    } catch (e) {
      AppLogger.error('Unexpected error during logout: $e', 'AUTH_API', e);
      throw ServerException(message: 'Unexpected error during logout: $e');
    }
  }
}
