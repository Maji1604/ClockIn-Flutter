import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration class to manage environment variables
class ApiConfig {
  static String? _baseUrl;
  static String? _fallbackBaseUrl;

  static String _normalize(String url) {
    return url.trim().replaceFirst(RegExp(r'/+$'), '');
  }

  /// Initialize the API configuration
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");

      // Primary URL from .env or dart-define
      _baseUrl = dotenv.env['API_BASE_URL'];

      // Support a comma-separated list of URLs via API_BASE_URLS
      final urlsRaw = dotenv.env['API_BASE_URLS'];
      if (urlsRaw != null && urlsRaw.trim().isNotEmpty) {
        final urls = urlsRaw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (urls.isNotEmpty) {
          _baseUrl ??= urls.first;
          if (urls.length > 1) {
            _fallbackBaseUrl = urls[1];
          }
        }
      }

      // Optional explicit fallback
      _fallbackBaseUrl =
          _fallbackBaseUrl ?? dotenv.env['API_BASE_URL_FALLBACK'];

      // Normalize
      if (_baseUrl != null && _baseUrl!.isNotEmpty) {
        _baseUrl = _normalize(_baseUrl!);
      }
      if (_fallbackBaseUrl != null && _fallbackBaseUrl!.isNotEmpty) {
        _fallbackBaseUrl = _normalize(_fallbackBaseUrl!);
      }
    } catch (e) {
      print('Failed to load .env file: $e');
      // In release builds, if .env fails to load, we need the URL to be configured
      // You should set this during build time or use --dart-define
      _baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
      final urlsRaw = const String.fromEnvironment(
        'API_BASE_URLS',
        defaultValue: '',
      );
      if (urlsRaw.isNotEmpty) {
        final urls = urlsRaw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (urls.isNotEmpty) {
          _baseUrl = _baseUrl!.isNotEmpty ? _baseUrl : urls.first;
          if (urls.length > 1) {
            _fallbackBaseUrl = urls[1];
          }
        }
      }
      _fallbackBaseUrl =
          _fallbackBaseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL_FALLBACK',
            defaultValue: '',
          );

      if (_baseUrl != null && _baseUrl!.isNotEmpty) {
        _baseUrl = _normalize(_baseUrl!);
      }
      if (_fallbackBaseUrl != null && _fallbackBaseUrl!.isNotEmpty) {
        _fallbackBaseUrl = _normalize(_fallbackBaseUrl!);
      }
    }

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      print('WARNING: API_BASE_URL is not configured!');
      print('Set it in .env file or use --dart-define=API_BASE_URL=<url>');
    }
  }

  /// Get the base URL for API calls
  static String get baseUrl {
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      throw Exception(
        'API_BASE_URL not configured. '
        'Add it to .env file or build with --dart-define=API_BASE_URL=<url>',
      );
    }
    return _baseUrl!;
  }

  /// Optional fallback base URL
  static String? get fallbackBaseUrl =>
      (_fallbackBaseUrl != null && _fallbackBaseUrl!.isNotEmpty)
      ? _fallbackBaseUrl
      : null;

  /// Check if API is configured
  static bool get isConfigured => _baseUrl != null && _baseUrl!.isNotEmpty;

  /// Whether a fallback base URL is configured
  static bool get hasFallback => fallbackBaseUrl != null;
}
