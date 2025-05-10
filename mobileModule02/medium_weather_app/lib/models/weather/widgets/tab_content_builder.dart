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
    WeatherData? weatherData,
    bool isLoadingWeather = false,
  }) {
    // Use provided weather data or fallback to mock if not available
    final WeatherData data = weatherData ?? WeatherData.mock();

    // Show loading if either location or weather data is being loaded
    final bool isLoading = isLoadingLocation || isLoadingWeather;

    return [
      // Currently tab content
      isLoading
          ? _buildLoadingTab()
          : CurrentlyScreen(
              weather: data.current,
              location: selectedLocation,
            ),

      // Today tab content
      isLoading
          ? _buildLoadingTab()
          : TodayScreen(
              hourlyForecasts: data.hourly,
              location: selectedLocation,
            ),

      // Weekly tab content
      isLoading
          ? _buildLoadingTab()
          : WeeklyScreen(
              dailyForecasts: data.daily,
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