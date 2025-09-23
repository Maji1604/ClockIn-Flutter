/// Core non-sensitive constants used throughout the application
///
/// This file contains only non-sensitive configuration values.
/// Sensitive data like API URLs, keys, and secrets are stored in environment variables.
library;

class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Storage Keys (local storage keys are not sensitive)
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String biometricEnabledKey = 'biometric_enabled';

  // Route Names
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String attendanceRoute = '/attendance';
  static const String leaveRoute = '/leave';
  static const String payrollRoute = '/payroll';
  static const String employeesRoute = '/employees';
  static const String reportsRoute = '/reports';
  static const String notificationsRoute = '/notifications';

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  static const String emailPattern = r'^[\w\.-]+@[\w\.-]+\.\w+$';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]+$';
  static const String namePattern = r'^[a-zA-Z\s]+$';

  // UI Layout Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultMargin = 16.0;
  static const double smallMargin = 8.0;
  static const double largeMargin = 24.0;

  static const double borderRadius = 8.0;
  static const double smallBorderRadius = 4.0;
  static const double largeBorderRadius = 16.0;
  static const double circularBorderRadius = 50.0;

  static const double defaultElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  // Icon Sizes
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;

  // Font Sizes
  static const double smallFontSize = 12.0;
  static const double defaultFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 18.0;
  static const double titleFontSize = 20.0;
  static const double headingFontSize = 24.0;
  static const double displayFontSize = 32.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Network Timeouts (non-sensitive timing values)
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration longTimeout = Duration(seconds: 60);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
  ];

  // Date Formats
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';

  // HR Specific Constants
  static const List<String> employeeStatuses = [
    'Active',
    'Inactive',
    'Terminated',
    'On Leave',
  ];
  static const List<String> leaveTypes = [
    'Annual',
    'Sick',
    'Maternity',
    'Paternity',
    'Emergency',
    'Unpaid',
  ];
  static const List<String> attendanceStatuses = [
    'Present',
    'Absent',
    'Late',
    'Half Day',
    'On Leave',
  ];
  static const List<String> departments = [
    'HR',
    'Finance',
    'IT',
    'Marketing',
    'Operations',
    'Sales',
  ];
  static const List<String> positions = [
    'Manager',
    'Senior',
    'Junior',
    'Intern',
    'Executive',
    'Director',
  ];

  // Working Hours
  static const int standardWorkingHours = 8;
  static const int maxOvertimeHours = 4;
  static const String standardStartTime = '09:00';
  static const String standardEndTime = '17:00';

  // Break Times (in minutes)
  static const int lunchBreakMinutes = 60;
  static const int shortBreakMinutes = 15;

  // Grace Period (in minutes)
  static const int lateArrivalGraceMinutes = 15;
  static const int earlyDepartureGraceMinutes = 15;

  // Notification Types
  static const String attendanceNotification = 'attendance';
  static const String leaveNotification = 'leave';
  static const String payrollNotification = 'payroll';
  static const String announcementNotification = 'announcement';
  static const String systemNotification = 'system';

  // Cache Keys
  static const String employeesListCache = 'employees_list';
  static const String attendanceCache = 'attendance_data';
  static const String leaveBalanceCache = 'leave_balance';
  static const String notificationsCache = 'notifications';

  // Error Messages
  static const String networkErrorMessage =
      'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unauthorizedMessage =
      'Session expired. Please login again.';
  static const String validationErrorMessage =
      'Please check the entered information.';
  static const String unknownErrorMessage =
      'Something went wrong. Please try again.';
}
