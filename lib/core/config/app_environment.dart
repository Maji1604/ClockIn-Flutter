import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

/// Environment configuration manager for the Creoleap HRMS application.
///
/// This class provides a centralized way to access environment variables
/// loaded from the .env file. It includes type-safe getters for different
/// types of configuration values.
class AppEnvironment {
  /// Initialize the environment by loading the .env file.
  ///
  /// This should be called in main() before runApp().
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file doesn't exist, continue with default values
      // This allows the app to run even without .env file
      AppLogger.warning(
        'Could not load .env file. Using default values.',
        'ENVIRONMENT',
      );
    }
  }

  // ==============================================
  // APPLICATION CONFIGURATION
  // ==============================================

  static String get appName => _getEnvVar('APP_NAME', 'Creoleap HRMS');
  static String get appVersion => _getEnvVar('APP_VERSION', '1.0.0');
  static String get appEnvironment => _getEnvVar('APP_ENVIRONMENT', 'development');
  static bool get isDebug => _getEnvVar('APP_DEBUG', 'false').toLowerCase() == 'true';

  /// Helper method to safely get environment variables
  static String _getEnvVar(String key, String defaultValue) {
    try {
      if (!dotenv.isInitialized) return defaultValue;
      return dotenv.env[key] ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // ==============================================
  // API CONFIGURATION
  // ==============================================

  static String get apiBaseUrl => _getEnvVar('API_BASE_URL', 'https://api.example.com/v1');
  static String get apiVersion => _getEnvVar('API_VERSION', 'v1');
  static int get apiTimeout => int.tryParse(_getEnvVar('API_TIMEOUT', '30000')) ?? 30000;
  static String get apiKey => _getEnvVar('API_KEY', '');
  static int get connectTimeout =>
      int.tryParse(_getEnvVar('CONNECT_TIMEOUT', '30000')) ?? 30000;
  static int get receiveTimeout =>
      int.tryParse(_getEnvVar('RECEIVE_TIMEOUT', '30000')) ?? 30000;

  // ==============================================
  // AUTHENTICATION & SECURITY
  // ==============================================

  static String get jwtSecretKey => _getEnvVar('JWT_SECRET_KEY', '');
  static String get jwtRefreshSecret => _getEnvVar('JWT_REFRESH_SECRET', '');
  static int get jwtExpiryHours =>
      int.tryParse(_getEnvVar('JWT_EXPIRY_HOURS', '24')) ?? 24;
  static int get refreshTokenExpiryDays =>
      int.tryParse(_getEnvVar('REFRESH_TOKEN_EXPIRY_DAYS', '30')) ?? 30;
  static String get encryptionKey => _getEnvVar('ENCRYPTION_KEY', '');
  static int get saltRounds =>
      int.tryParse(_getEnvVar('SALT_ROUNDS', '12')) ?? 12;

  // ==============================================
  // DATABASE CONFIGURATION
  // ==============================================

  static String get dbHost => _getEnvVar('DB_HOST', 'localhost');
  static int get dbPort => int.tryParse(_getEnvVar('DB_PORT', '5432')) ?? 5432;
  static String get dbName => _getEnvVar('DB_NAME', '');
  static String get dbUsername => _getEnvVar('DB_USERNAME', '');
  static String get dbPassword => _getEnvVar('DB_PASSWORD', '');
  static bool get dbSsl => _getEnvVar('DB_SSL', 'false').toLowerCase() == 'true';

  // ==============================================
  // THIRD-PARTY SERVICES
  // ==============================================

  // Email Service
  static String get emailServiceApiKey =>
      _getEnvVar('EMAIL_SERVICE_API_KEY', '');
  static String get emailFromAddress => _getEnvVar('EMAIL_FROM_ADDRESS', '');
  static String get emailFromName => _getEnvVar('EMAIL_FROM_NAME', '');

  // SMS Service
  static String get smsServiceSid => _getEnvVar('SMS_SERVICE_SID', '');
  static String get smsAuthToken => _getEnvVar('SMS_AUTH_TOKEN', '');
  static String get smsPhoneNumber => _getEnvVar('SMS_PHONE_NUMBER', '');

  // File Storage
  static String get storageServiceKey =>
      _getEnvVar('STORAGE_SERVICE_KEY', '');
  static String get storageBucketName =>
      _getEnvVar('STORAGE_BUCKET_NAME', '');
  static String get storageRegion => _getEnvVar('STORAGE_REGION', '');

  // Push Notifications
  static String get firebaseServerKey =>
      _getEnvVar('FIREBASE_SERVER_KEY', '');
  static String get firebaseProjectId =>
      _getEnvVar('FIREBASE_PROJECT_ID', '');

  // ==============================================
  // OAUTH & SOCIAL LOGIN
  // ==============================================

  // Google OAuth
  static String get googleClientId => _getEnvVar('GOOGLE_CLIENT_ID', '');
  static String get googleClientSecret =>
      _getEnvVar('GOOGLE_CLIENT_SECRET', '');

  // Microsoft OAuth
  static String get microsoftClientId =>
      _getEnvVar('MICROSOFT_CLIENT_ID', '');
  static String get microsoftClientSecret =>
      _getEnvVar('MICROSOFT_CLIENT_SECRET', '');

  // ==============================================
  // PAYMENT CONFIGURATION
  // ==============================================

  // Stripe
  static String get stripePublishableKey =>
      _getEnvVar('STRIPE_PUBLISHABLE_KEY', '');
  static String get stripeSecretKey => _getEnvVar('STRIPE_SECRET_KEY', '');

  // PayPal
  static String get paypalClientId => _getEnvVar('PAYPAL_CLIENT_ID', '');
  static String get paypalClientSecret =>
      _getEnvVar('PAYPAL_CLIENT_SECRET', '');
  static String get paypalMode => _getEnvVar('PAYPAL_MODE', 'sandbox');

  // ==============================================
  // EXTERNAL INTEGRATIONS
  // ==============================================

  static String get timeTrackingApiKey =>
      _getEnvVar('TIME_TRACKING_API_KEY', '');
  static String get biometricApiKey => _getEnvVar('BIOMETRIC_API_KEY', '');
  static String get biometricApiUrl => _getEnvVar('BIOMETRIC_API_URL', '');
  static String get analyticsApiKey => _getEnvVar('ANALYTICS_API_KEY', '');

  // ==============================================
  // FEATURE FLAGS
  // ==============================================

  static bool get enableBiometricAuth =>
      _getEnvVar('ENABLE_BIOMETRIC_AUTH', 'false').toLowerCase() == 'true';
  static bool get enableFacialRecognition =>
      _getEnvVar('ENABLE_FACIAL_RECOGNITION', 'false').toLowerCase() == 'true';
  static bool get enableGeolocationTracking =>
      _getEnvVar('ENABLE_GEOLOCATION_TRACKING', 'false').toLowerCase() == 'true';
  static bool get enableOfflineMode =>
      _getEnvVar('ENABLE_OFFLINE_MODE', 'false').toLowerCase() == 'true';

  // ==============================================
  // TESTING
  // ==============================================

  static String get testUserEmail => _getEnvVar('TEST_USER_EMAIL', '');
  static String get testUserPassword => _getEnvVar('TEST_USER_PASSWORD', '');

  // ==============================================
  // UTILITY METHODS
  // ==============================================

  /// Check if running in production environment
  static bool get isProduction => appEnvironment.toLowerCase() == 'production';

  /// Check if running in development environment
  static bool get isDevelopment =>
      appEnvironment.toLowerCase() == 'development';

  /// Check if running in staging environment
  static bool get isStaging => appEnvironment.toLowerCase() == 'staging';

  /// Get a custom environment variable
  static String? getCustomVar(String key) => _getEnvVar(key, '');

  /// Get a custom environment variable with default value
  static String getCustomVarOrDefault(String key, String defaultValue) =>
      _getEnvVar(key, defaultValue);

  /// Print all loaded environment variables (for debugging)
  /// Only use this in development mode
  static void printEnvironmentVariables() {
    if (isDebug && isDevelopment) {
      AppLogger.debug('=== LOADED ENVIRONMENT VARIABLES ===', 'ENVIRONMENT');
      try {
        if (dotenv.isInitialized) {
          dotenv.env.forEach((key, value) {
            // Hide sensitive values in logs
            if (_isSensitiveKey(key)) {
              AppLogger.debug('$key: ***HIDDEN***', 'ENVIRONMENT');
            } else {
              AppLogger.debug('$key: $value', 'ENVIRONMENT');
            }
          });
        } else {
          AppLogger.debug('Dotenv not initialized - using default values', 'ENVIRONMENT');
        }
      } catch (e) {
        AppLogger.debug('Error reading environment variables: $e', 'ENVIRONMENT');
      }
      AppLogger.debug('====================================', 'ENVIRONMENT');
    }
  }

  /// Check if a key contains sensitive information
  static bool _isSensitiveKey(String key) {
    final sensitiveKeywords = [
      'password',
      'secret',
      'key',
      'token',
      'auth',
      'api_key',
      'client_secret',
      'private',
    ];

    final lowerKey = key.toLowerCase();
    return sensitiveKeywords.any((keyword) => lowerKey.contains(keyword));
  }
}
