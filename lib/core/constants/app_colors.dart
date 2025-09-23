import 'package:flutter/material.dart';

/// Color constants for the Creoleap HRMS application
///
/// This class defines the color palette used throughout the app
/// following Material Design guidelines and brand colors.
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color secondary = Color(0xFF03DAC6); // Teal
  static const Color secondaryDark = Color(0xFF018786);
  static const Color secondaryLight = Color(0xFFB2DFDB);

  // Accent Colors
  static const Color accent = Color(0xFFFF5722); // Deep Orange
  static const Color accentLight = Color(0xFFFFCCBC);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF000000);

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color error = Color(0xFFF44336); // Red
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color info = Color(0xFF2196F3); // Blue
  static const Color infoLight = Color(0xFFBBDEFB);

  // Functional Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1F000000);
  static const Color overlay = Color(0x66000000);

  // HR Specific Colors
  static const Color attendance = Color(0xFF4CAF50); // Green for present
  static const Color absent = Color(0xFFF44336); // Red for absent
  static const Color leave = Color(0xFFFF9800); // Orange for leave
  static const Color holiday = Color(0xFF9C27B0); // Purple for holidays
  static const Color overtime = Color(0xFF3F51B5); // Indigo for overtime

  // Department Colors (for visual categorization)
  static const Color hr = Color(0xFFE91E63); // Pink
  static const Color finance = Color(0xFF4CAF50); // Green
  static const Color it = Color(0xFF2196F3); // Blue
  static const Color marketing = Color(0xFFFF9800); // Orange
  static const Color operations = Color(0xFF9C27B0); // Purple
  static const Color sales = Color(0xFF607D8B); // Blue Grey

  // Priority Colors
  static const Color priorityHigh = Color(0xFFF44336); // Red
  static const Color priorityMedium = Color(0xFFFF9800); // Orange
  static const Color priorityLow = Color(0xFF4CAF50); // Green

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF21CBF3),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFB74D),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFE57373),
  ];

  // Chart Colors (for analytics and reports)
  static const List<Color> chartColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF795548), // Brown
    Color(0xFFE91E63), // Pink
  ];

  // Transparency Levels
  static const double opacity10 = 0.1;
  static const double opacity20 = 0.2;
  static const double opacity30 = 0.3;
  static const double opacity40 = 0.4;
  static const double opacity50 = 0.5;
  static const double opacity60 = 0.6;
  static const double opacity70 = 0.7;
  static const double opacity80 = 0.8;
  static const double opacity90 = 0.9;

  // Helper Methods

  /// Get color with specified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get status color based on boolean value
  static Color getStatusColor(bool isPositive) {
    return isPositive ? success : error;
  }

  /// Get priority color based on priority level (1-3, where 1 is highest)
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return priorityHigh;
      case 2:
        return priorityMedium;
      case 3:
      default:
        return priorityLow;
    }
  }

  /// Get department color based on department name
  static Color getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'hr':
      case 'human resources':
        return hr;
      case 'finance':
      case 'accounting':
        return finance;
      case 'it':
      case 'information technology':
        return it;
      case 'marketing':
        return marketing;
      case 'operations':
        return operations;
      case 'sales':
        return sales;
      default:
        return primary;
    }
  }

  /// Get attendance color based on status
  static Color getAttendanceColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'on time':
        return attendance;
      case 'absent':
        return absent;
      case 'leave':
      case 'on leave':
        return leave;
      case 'holiday':
        return holiday;
      case 'overtime':
        return overtime;
      default:
        return textSecondary;
    }
  }
}
