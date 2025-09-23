# Constants & Environment Configuration

This document explains the separation of sensitive and non-sensitive configuration in the Creoleap HRMS application.

## 📁 File Structure

### `lib/core/constants/app_constants.dart`
**Purpose:** Non-sensitive application constants
- UI layout values (padding, margins, border radius)
- Validation rules and patterns
- Route names
- Storage keys (local storage keys are not sensitive)
- HR-specific constants (departments, leave types, etc.)
- Error messages and cache keys

### `lib/core/constants/app_colors.dart`
**Purpose:** Color palette and theme definitions
- Brand colors (primary, secondary, accent)
- Status colors (success, warning, error, info)
- Text colors for different contexts
- HR-specific colors (attendance, departments, priorities)
- Gradient definitions and chart colors
- Helper methods for dynamic color selection

### `lib/core/config/app_environment.dart`
**Purpose:** Environment-based configuration (sensitive data)
- API URLs and keys
- Database connection strings
- JWT secrets and encryption keys
- Third-party service credentials
- OAuth client IDs and secrets
- Payment service keys

### `.env` File
**Purpose:** Actual sensitive values (not committed to git)
- Contains real API keys, URLs, and secrets
- Environment-specific configuration
- Excluded from version control via `.gitignore`

### `.env.example` File
**Purpose:** Template for environment variables
- Shows structure of required variables
- Safe to commit to version control
- Used by developers to create their own `.env` file

## 🔄 Migration Summary

### Moved FROM AppConstants TO AppEnvironment:
- `baseUrl` → `AppEnvironment.apiBaseUrl`
- `apiVersion` → `AppEnvironment.apiVersion`
- `connectTimeout` → `AppEnvironment.connectTimeout`
- `receiveTimeout` → `AppEnvironment.receiveTimeout`
- `appName` → `AppEnvironment.appName`
- `appVersion` → `AppEnvironment.appVersion`

### Added New Color System:
- Comprehensive color palette with brand colors
- HR-specific color coding for departments and statuses
- Status colors for success, warning, error states
- Helper methods for dynamic color selection
- Gradient definitions for modern UI effects

### Security Improvements:
- Sensitive data moved to environment variables
- `.env` file excluded from git commits
- Type-safe access to environment variables with fallbacks
- Sensitive values hidden in debug logs

## 🎨 Using Colors

```dart
import 'package:creoleap_hrms/core/core.dart';

// Brand colors
Container(color: AppColors.primary)
Text(style: TextStyle(color: AppColors.textPrimary))

// Status colors
Icon(color: AppColors.success) // Green for success
Container(color: AppColors.error) // Red for errors

// HR-specific colors
Container(color: AppColors.getDepartmentColor('IT')) // Blue for IT dept
Icon(color: AppColors.getAttendanceColor('Present')) // Green for present

// Dynamic colors with opacity
Container(color: AppColors.withOpacity(AppColors.primary, 0.5))
```

## 🔧 Using Environment Variables

```dart
import 'package:creoleap_hrms/core/core.dart';

// API configuration
final apiUrl = AppEnvironment.apiBaseUrl;
final apiKey = AppEnvironment.apiKey;
final timeout = AppEnvironment.apiTimeout;

// Environment detection
if (AppEnvironment.isProduction) {
  // Production logic
} else if (AppEnvironment.isDevelopment) {
  // Development logic
}

// Feature flags
if (AppEnvironment.enableBiometricAuth) {
  // Show biometric options
}
```

## 🔒 Security Best Practices

1. **Never commit `.env` file** - Contains real secrets
2. **Use `.env.example`** - Template for team members
3. **Environment detection** - Different configs for dev/staging/production
4. **Fallback values** - App works even without `.env` file
5. **Sensitive data hiding** - Secrets masked in debug logs

## 📋 Developer Setup

1. Copy `.env.example` to `.env`
2. Fill in your actual API keys and URLs
3. Never commit the `.env` file
4. Use `AppEnvironment` class to access values
5. Use `AppConstants` for non-sensitive configuration
6. Use `AppColors` for consistent theming

## 🎯 Benefits

- **Security:** Sensitive data separated from code
- **Flexibility:** Different configs for different environments
- **Maintainability:** Centralized configuration management
- **Consistency:** Unified color system across the app
- **Type Safety:** Compile-time checks for configuration access