import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration class to manage environment variables
class ApiConfig {
  static String? _baseUrl;
  
  /// Initialize the API configuration
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      _baseUrl = dotenv.env['API_BASE_URL'];
    } catch (e) {
      print('Failed to load .env file: $e');
      // In release builds, if .env fails to load, we need the URL to be configured
      // You should set this during build time or use --dart-define
      _baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '',
      );
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
        'Add it to .env file or build with --dart-define=API_BASE_URL=<url>'
      );
    }
    return _baseUrl!;
  }
  
  /// Check if API is configured
  static bool get isConfigured => _baseUrl != null && _baseUrl!.isNotEmpty;
}
