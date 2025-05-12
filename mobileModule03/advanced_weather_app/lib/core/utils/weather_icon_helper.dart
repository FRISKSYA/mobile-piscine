import 'package:flutter/material.dart';

/// Helper class for getting weather condition icons
class WeatherIconHelper {
  /// Returns the appropriate icon for the weather condition
  static IconData getWeatherIcon(String condition) {
    final String lowerCondition = condition.toLowerCase();

    if (lowerCondition.contains('sun') || lowerCondition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (lowerCondition.contains('part') && lowerCondition.contains('cloud')) {
      return Icons.wb_cloudy;
    } else if (lowerCondition.contains('cloud')) {
      return Icons.cloud;
    } else if (lowerCondition.contains('rain')) {
      return Icons.grain;
    } else if (lowerCondition.contains('snow')) {
      return Icons.ac_unit;
    } else if (lowerCondition.contains('thunder') || lowerCondition.contains('storm')) {
      return Icons.flash_on;
    } else if (lowerCondition.contains('fog') || lowerCondition.contains('mist')) {
      return Icons.cloud_queue;
    } else {
      return Icons.cloud; // Default icon
    }
  }
}