import 'package:dio/dio.dart';
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
        baseUrl: '${AppEnvironment.apiBaseUrl}/${AppEnvironment.apiVersion}',
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
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Add authentication token from storage
    // final token = getAuthToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    super.onRequest(options, handler);
  }
}
