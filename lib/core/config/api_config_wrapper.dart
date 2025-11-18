import 'api_config.dart';

/// Wrapper class to allow ApiConfig to be passed as an instance
class ApiConfigWrapper {
  String get baseUrl => ApiConfig.baseUrl;
  String? get fallbackBaseUrl => ApiConfig.fallbackBaseUrl;
}
