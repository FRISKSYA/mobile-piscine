/// Constants used throughout the app
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App information
  static const String appName = 'Weather App';
  static const String appVersion = '1.0.0';

  // Tab names
  static const String currentlyTabName = 'Currently';
  static const String todayTabName = 'Today';
  static const String weeklyTabName = 'Weekly';

  // UI constants
  static const double smallScreenWidth = 600;
  static const double maxIconSize = 100;
  static const double maxHeadingFontSize = 32;
  static const double maxBodyFontSize = 20;

  // API constants (for future use)
  static const String apiBaseUrl = 'placeholder-for-weather-api-url';
  static const int apiTimeoutSeconds = 30;
}