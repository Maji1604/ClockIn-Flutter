import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_environment.dart';
import '../utils/logger.dart';

/// HTTP client configuration and setup
class HttpClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppEnvironment.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppEnvironment.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(_LoggingInterceptor());
    dio.interceptors.add(_AuthInterceptor());

    return dio;
  }
}

/// Logging interceptor for HTTP requests/responses
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('REQUEST: ${options.method} ${options.uri}', 'HTTP');
    if (options.data != null) {
      AppLogger.debug('Request Data: ${options.data}', 'HTTP');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
      'RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
      'HTTP',
    );
    AppLogger.debug('Response Data: ${response.data}', 'HTTP');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'HTTP ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}',
      'HTTP',
      err,
      err.stackTrace,
    );
    super.onError(err, handler);
  }
}

/// Authentication interceptor for adding auth headers
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Get token from storage if available
      final sharedPrefs = await SharedPreferences.getInstance();
      final token = sharedPrefs.getString('auth_token');
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      
      // Get company slug from storage if available
      final userJson = sharedPrefs.getString('auth_user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final companySlug = userMap['company_slug'] as String?;
        
        if (companySlug != null) {
          options.headers['X-Company-ID'] = companySlug;
        }
      }
    } catch (e) {
      AppLogger.warning('Failed to add auth headers: $e', 'HTTP');
    }
    
    super.onRequest(options, handler);
  }
}
