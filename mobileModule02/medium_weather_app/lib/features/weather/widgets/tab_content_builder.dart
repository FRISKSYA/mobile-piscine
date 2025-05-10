import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../models/forecast.dart';
import '../../../models/geocoding/location.dart';
import '../../../models/weather.dart';
import '../../../screens/currently_screen.dart';
import '../../../screens/today_screen.dart';
import '../../../screens/weekly_screen.dart';

class TabContentBuilder {
  /// Creates a subtitle text for a tab based on the current location
  static String getTabSubtitle(String tabName, String currentLocation) {
    return currentLocation.isEmpty
        ? 'This is the $tabName tab content'
        : currentLocation;
  }

  /// Builds all tab content widgets with weather data
  static List<Widget> buildTabContents({
    required String currentLocation,
    required bool isUsingGeolocation,
    required String coordinatesText,
    required bool isLoadingLocation,
    Location? selectedLocation,
  }) {
    // Generate mock weather data
    final weatherData = WeatherData.mock();

    return [
      // Currently tab content
      isLoadingLocation
          ? _buildLoadingTab()
          : CurrentlyScreen(
              weather: weatherData.current,
              location: selectedLocation,
            ),

      // Today tab content
      isLoadingLocation
          ? _buildLoadingTab()
          : TodayScreen(
              hourlyForecasts: weatherData.hourly,
              location: selectedLocation,
            ),

      // Weekly tab content
      isLoadingLocation
          ? _buildLoadingTab()
          : WeeklyScreen(
              dailyForecasts: weatherData.daily,
              location: selectedLocation,
            ),
    ];
  }

  /// Build a loading indicator tab
  static Widget _buildLoadingTab() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}