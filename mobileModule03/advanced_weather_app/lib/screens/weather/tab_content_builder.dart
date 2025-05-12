import 'package:flutter/material.dart';
import '../../models/forecast/forecast.dart';
import '../../models/location/location.dart';
import 'currently_screen.dart';
import 'today_screen.dart';
import 'weekly_screen.dart';

class TabContentBuilder {
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
    // If no weather data is available, we'll show empty state screens

    // Show loading if either location or weather data is being loaded
    final bool isLoading = isLoadingLocation || isLoadingWeather;

    return [
      // Currently tab content
      isLoading
          ? _buildLoadingTab()
          : weatherData == null
              ? _buildNoDataTab("No current weather data available")
              : CurrentlyScreen(
                  weather: weatherData.current,
                  location: selectedLocation,
                ),

      // Today tab content
      isLoading
          ? _buildLoadingTab()
          : weatherData == null
              ? _buildNoDataTab("No hourly forecast data available")
              : weatherData.hourly.isEmpty
                  ? _buildNoDataTab("No hourly forecast data available")
                  : TodayScreen(
                      hourlyForecasts: weatherData.hourly,
                      location: selectedLocation,
                    ),

      // Weekly tab content
      isLoading
          ? _buildLoadingTab()
          : weatherData == null
              ? _buildNoDataTab("No weekly forecast data available")
              : weatherData.daily.isEmpty
                  ? _buildNoDataTab("No weekly forecast data available")
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

  /// Build a tab for when no data is available
  static Widget _buildNoDataTab(String message) {
    return Center(
      child: Card(
        elevation: 3,
        color: Color.fromRGBO(255, 255, 255, 0.85), // Semi-transparent white background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Please check your connection and try again",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}