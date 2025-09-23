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

  static String get appName => dotenv.env['APP_NAME'] ?? 'Creoleap HRMS';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get appEnvironment =>
      dotenv.env['APP_ENVIRONMENT'] ?? 'development';
  static bool get isDebug => dotenv.env['APP_DEBUG']?.toLowerCase() == 'true';

  // ==============================================
  // API CONFIGURATION
  // ==============================================

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.example.com/v1';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '') ?? 30000;
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static int get connectTimeout =>
      int.tryParse(dotenv.env['CONNECT_TIMEOUT'] ?? '') ?? 30000;
  static int get receiveTimeout =>
      int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '') ?? 30000;

  // ==============================================
  // AUTHENTICATION & SECURITY
  // ==============================================

  static String get jwtSecretKey => dotenv.env['JWT_SECRET_KEY'] ?? '';
  static String get jwtRefreshSecret => dotenv.env['JWT_REFRESH_SECRET'] ?? '';
  static int get jwtExpiryHours =>
      int.tryParse(dotenv.env['JWT_EXPIRY_HOURS'] ?? '') ?? 24;
  static int get refreshTokenExpiryDays =>
      int.tryParse(dotenv.env['REFRESH_TOKEN_EXPIRY_DAYS'] ?? '') ?? 30;
  static String get encryptionKey => dotenv.env['ENCRYPTION_KEY'] ?? '';
  static int get saltRounds =>
      int.tryParse(dotenv.env['SALT_ROUNDS'] ?? '') ?? 12;

  // ==============================================
  // DATABASE CONFIGURATION
  // ==============================================

  static String get dbHost => dotenv.env['DB_HOST'] ?? 'localhost';
  static int get dbPort => int.tryParse(dotenv.env['DB_PORT'] ?? '') ?? 5432;
  static String get dbName => dotenv.env['DB_NAME'] ?? '';
  static String get dbUsername => dotenv.env['DB_USERNAME'] ?? '';
  static String get dbPassword => dotenv.env['DB_PASSWORD'] ?? '';
  static bool get dbSsl => dotenv.env['DB_SSL']?.toLowerCase() == 'true';

  // ==============================================
  // THIRD-PARTY SERVICES
  // ==============================================

  // Email Service
  static String get emailServiceApiKey =>
      dotenv.env['EMAIL_SERVICE_API_KEY'] ?? '';
  static String get emailFromAddress => dotenv.env['EMAIL_FROM_ADDRESS'] ?? '';
  static String get emailFromName => dotenv.env['EMAIL_FROM_NAME'] ?? '';

  // SMS Service
  static String get smsServiceSid => dotenv.env['SMS_SERVICE_SID'] ?? '';
  static String get smsAuthToken => dotenv.env['SMS_AUTH_TOKEN'] ?? '';
  static String get smsPhoneNumber => dotenv.env['SMS_PHONE_NUMBER'] ?? '';

  // File Storage
  static String get storageServiceKey =>
      dotenv.env['STORAGE_SERVICE_KEY'] ?? '';
  static String get storageBucketName =>
      dotenv.env['STORAGE_BUCKET_NAME'] ?? '';
  static String get storageRegion => dotenv.env['STORAGE_REGION'] ?? '';

  // Push Notifications
  static String get firebaseServerKey =>
      dotenv.env['FIREBASE_SERVER_KEY'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  // ==============================================
  // OAUTH & SOCIAL LOGIN
  // ==============================================

  // Google OAuth
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get googleClientSecret =>
      dotenv.env['GOOGLE_CLIENT_SECRET'] ?? '';

  // Microsoft OAuth
  static String get microsoftClientId =>
      dotenv.env['MICROSOFT_CLIENT_ID'] ?? '';
  static String get microsoftClientSecret =>
      dotenv.env['MICROSOFT_CLIENT_SECRET'] ?? '';

  // ==============================================
  // PAYMENT CONFIGURATION
  // ==============================================

  // Stripe
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  // PayPal
  static String get paypalClientId => dotenv.env['PAYPAL_CLIENT_ID'] ?? '';
  static String get paypalClientSecret =>
      dotenv.env['PAYPAL_CLIENT_SECRET'] ?? '';
  static String get paypalMode => dotenv.env['PAYPAL_MODE'] ?? 'sandbox';

  // ==============================================
  // EXTERNAL INTEGRATIONS
  // ==============================================

  static String get timeTrackingApiKey =>
      dotenv.env['TIME_TRACKING_API_KEY'] ?? '';
  static String get biometricApiKey => dotenv.env['BIOMETRIC_API_KEY'] ?? '';
  static String get biometricApiUrl => dotenv.env['BIOMETRIC_API_URL'] ?? '';
  static String get analyticsApiKey => dotenv.env['ANALYTICS_API_KEY'] ?? '';

  // ==============================================
  // FEATURE FLAGS
  // ==============================================

  static bool get enableBiometricAuth =>
      dotenv.env['ENABLE_BIOMETRIC_AUTH']?.toLowerCase() == 'true';
  static bool get enableFacialRecognition =>
      dotenv.env['ENABLE_FACIAL_RECOGNITION']?.toLowerCase() == 'true';
  static bool get enableGeolocationTracking =>
      dotenv.env['ENABLE_GEOLOCATION_TRACKING']?.toLowerCase() == 'true';
  static bool get enableOfflineMode =>
      dotenv.env['ENABLE_OFFLINE_MODE']?.toLowerCase() == 'true';

  // ==============================================
  // TESTING
  // ==============================================

  static String get testUserEmail => dotenv.env['TEST_USER_EMAIL'] ?? '';
  static String get testUserPassword => dotenv.env['TEST_USER_PASSWORD'] ?? '';

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
  static String? getCustomVar(String key) => dotenv.env[key];

  /// Get a custom environment variable with default value
  static String getCustomVarOrDefault(String key, String defaultValue) =>
      dotenv.env[key] ?? defaultValue;

  /// Print all loaded environment variables (for debugging)
  /// Only use this in development mode
  static void printEnvironmentVariables() {
    if (isDebug && isDevelopment) {
      AppLogger.debug('=== LOADED ENVIRONMENT VARIABLES ===', 'ENVIRONMENT');
      dotenv.env.forEach((key, value) {
        // Hide sensitive values in logs
        if (_isSensitiveKey(key)) {
          AppLogger.debug('$key: ***HIDDEN***', 'ENVIRONMENT');
        } else {
          AppLogger.debug('$key: $value', 'ENVIRONMENT');
        }
      });
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
