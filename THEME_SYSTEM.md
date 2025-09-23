# Theme System Documentation

This document explains the comprehensive light and dark mode theme system implemented in the Creoleap HRMS application.

## 📁 File Structure

### `lib/core/theme/app_theme.dart`
**Purpose:** Theme definitions for light and dark modes
- Comprehensive MaterialApp theme configurations
- Consistent styling across all widgets
- Typography system with proper text styles
- Color scheme integration with AppColors
- Component-specific themes (AppBar, Buttons, Cards, etc.)

### `lib/core/theme/theme_manager.dart`
**Purpose:** Theme state management and persistence
- Theme switching functionality
- Local storage persistence
- Change notifications for reactive UI updates
- Utility methods for theme detection

## 🎨 Theme Features

### **Comprehensive Theme Coverage:**
- ✅ **Light Theme** - Clean, professional light mode
- ✅ **Dark Theme** - Easy-on-eyes dark mode
- ✅ **System Theme** - Automatically follows device preference
- ✅ **Theme Persistence** - Remembers user choice across app sessions

### **Component Themes Included:**
- **AppBar** - Title, icons, elevation
- **Buttons** - Elevated, Outlined, Text buttons with consistent styling
- **Input Fields** - Borders, focus states, error states
- **Cards** - Elevation, shadows, borders
- **Navigation** - Bottom navigation, drawer
- **Typography** - Complete text theme with proper hierarchy
- **Icons** - Consistent sizing and colors

### **HR-Specific Color Integration:**
- Department-based color coding
- Attendance status colors
- Priority level indicators
- Success/Warning/Error states

## 🔧 Usage Examples

### **Basic Theme Usage:**
```dart
// The theme is automatically applied to all Material widgets
Scaffold(
  appBar: AppBar(title: Text('HRMS')), // Uses theme colors
  body: Card(child: Text('Content')),   // Uses theme card style
)
```

### **Manual Theme Access:**
```dart
// Access current theme
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

// Use theme colors
Container(
  color: theme.colorScheme.primary,
  child: Text(
    'Hello',
    style: theme.textTheme.headlineMedium,
  ),
)
```

### **Theme Manager Usage:**
```dart
// Switch themes programmatically
ThemeManager().setLightTheme();
ThemeManager().setDarkTheme();
ThemeManager().setSystemTheme();

// Toggle between light/dark
ThemeManager().toggleTheme();

// Check current theme
if (ThemeManager().isDarkMode) {
  // Dark mode specific logic
}

// Listen to theme changes
AnimatedBuilder(
  animation: ThemeManager(),
  builder: (context, child) {
    return Widget(); // Rebuilds when theme changes
  },
)
```

### **Theme Selection UI:**
```dart
// Theme selection dropdown (already implemented in SplashPage)
PopupMenuButton<ThemeMode>(
  icon: Icon(ThemeManager().getThemeIcon()),
  onSelected: (mode) => ThemeManager().setThemeMode(mode),
  itemBuilder: (context) {
    return ThemeManager().availableThemes.entries.map((entry) {
      return PopupMenuItem<ThemeMode>(
        value: entry.key,
        child: Row(
          children: [
            Icon(_getThemeIcon(entry.key)),
            SizedBox(width: 8),
            Text(entry.value),
          ],
        ),
      );
    }).toList();
  },
)
```

## 🚀 Implementation Details

### **1. App Integration:**
```dart
// main.dart - Theme system is fully integrated
MaterialApp(
  theme: AppTheme.lightTheme,      // Light theme
  darkTheme: AppTheme.darkTheme,   // Dark theme
  themeMode: ThemeManager().themeMode, // Current mode
  // App automatically switches based on themeMode
)
```

### **2. Persistence:**
- Theme choice is saved to `SharedPreferences`
- Automatically loads on app restart
- Uses `AppConstants.themeKey` for storage

### **3. Reactive Updates:**
- `ThemeManager` extends `ChangeNotifier`
- UI automatically rebuilds when theme changes
- No manual refresh needed

### **4. System Integration:**
- Respects system dark/light mode preference
- `ThemeMode.system` follows device settings
- Automatic switching when system changes

## 📱 User Experience

### **Theme Switching Options:**
1. **Light Mode** - Clean, bright interface for daytime use
2. **Dark Mode** - Reduced eye strain for low-light environments
3. **System Mode** - Automatically follows device preference

### **Visual Consistency:**
- All colors defined in `AppColors` class
- Consistent spacing using `AppConstants`
- Proper contrast ratios for accessibility
- Material Design 3 compliance

### **Performance:**
- Themes are created once and cached
- Fast switching with no rebuild delays
- Minimal memory footprint

## 🔄 Architecture Benefits

### **Separation of Concerns:**
- **AppColors** - Color definitions only
- **AppTheme** - Theme structure and widget styling  
- **ThemeManager** - State management and business logic
- **Main App** - Integration and usage

### **Maintainability:**
- Single source of truth for all colors
- Centralized theme configuration
- Easy to add new themes or modify existing ones
- Type-safe theme access

### **Extensibility:**
- Easy to add custom themes (e.g., high contrast)
- Support for theme variants (different brand colors)
- Custom component themes can be easily added

## 🎯 Next Steps

### **Potential Enhancements:**
1. **Custom Theme Colors** - Allow users to customize accent colors
2. **Theme Animations** - Smooth transitions between themes
3. **Accessibility Themes** - High contrast, large text variants
4. **Brand Themes** - Multiple corporate color schemes
5. **Seasonal Themes** - Holiday or seasonal color variations

### **Advanced Features:**
```dart
// Future enhancements could include:
class CustomThemeManager {
  void setCustomAccentColor(Color color);
  void enableHighContrastMode();
  void setFontScale(double scale);
  void enableColorBlindnessSupport();
}
```

## ✅ Current Status

- ✅ **Complete light/dark theme system**
- ✅ **Theme persistence and management**
- ✅ **Comprehensive component styling**
- ✅ **System integration and automatic switching**
- ✅ **User-friendly theme selection UI**
- ✅ **Full Material Design 3 compliance**
- ✅ **HR-specific color integration**
- ✅ **Performance optimized**

The theme system is now **production-ready** and provides a solid foundation for the entire HRMS application's visual design!