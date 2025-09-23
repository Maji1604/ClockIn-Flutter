import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Theme manager for handling theme switching and persistence
///
/// This class manages the current theme mode and provides methods
/// to switch between light, dark, and system themes.
class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.system;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if current theme is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Check if current theme follows system
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Check if current theme is light
  bool get isLightMode => _themeMode == ThemeMode.light;

  /// Initialize theme manager
  Future<void> initialize() async {
    try {
      await _loadThemeFromPreferences();
      AppLogger.info(
        'Theme manager initialized. Current mode: $_themeMode',
        'THEME',
      );
    } catch (e) {
      AppLogger.error('Failed to initialize theme manager: $e', 'THEME');
      _themeMode = ThemeMode.system;
    }
  }

  /// Load theme preference from local storage
  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(AppConstants.themeKey);

      if (themeString != null) {
        _themeMode = _stringToThemeMode(themeString);
        AppLogger.debug('Loaded theme from preferences: $themeString', 'THEME');
      } else {
        _themeMode = ThemeMode.system;
        AppLogger.debug(
          'No theme preference found, using system default',
          'THEME',
        );
      }
    } catch (e) {
      AppLogger.warning('Failed to load theme from preferences: $e', 'THEME');
      _themeMode = ThemeMode.system;
    }
  }

  /// Save theme preference to local storage
  Future<void> _saveThemeToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = _themeModeToString(_themeMode);
      await prefs.setString(AppConstants.themeKey, themeString);
      AppLogger.debug('Saved theme to preferences: $themeString', 'THEME');
    } catch (e) {
      AppLogger.error('Failed to save theme to preferences: $e', 'THEME');
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeToPreferences();
      notifyListeners();
      AppLogger.info('Theme changed to: ${_themeModeToString(mode)}', 'THEME');
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system mode, toggle to opposite of current system brightness
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set system theme (follows system brightness)
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Get theme name for display
  String getThemeName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get theme icon for UI
  IconData getThemeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Get appropriate theme icon for current brightness
  IconData getToggleIcon(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode;
  }

  /// Check if current theme matches system brightness
  bool isCurrentBrightness(BuildContext context, Brightness brightness) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == brightness;
    } else {
      return (_themeMode == ThemeMode.dark) == (brightness == Brightness.dark);
    }
  }

  /// Convert ThemeMode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string to ThemeMode
  ThemeMode _stringToThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Get all available theme modes with display names
  Map<ThemeMode, String> get availableThemes => {
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
    ThemeMode.system: 'System',
  };

  /// Reset theme to system default
  Future<void> resetTheme() async {
    await setThemeMode(ThemeMode.system);
    AppLogger.info('Theme reset to system default', 'THEME');
  }

  /// Get theme mode from string (for external configuration)
  static ThemeMode? themeModeFromString(String? mode) {
    if (mode == null) return null;

    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}
