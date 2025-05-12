import 'package:flutter/material.dart';
import '../../models/weather/weather.dart';
import '../../core/theme/app_theme.dart';
import '../../models/location/location.dart';

/// Screen to display current weather
class CurrentlyScreen extends StatelessWidget {
  final Weather weather;
  final Location? location;

  const CurrentlyScreen({
    super.key,
    required this.weather,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location information
          _buildLocationInfo(context),
          const SizedBox(height: 24),

          // Current weather info
          _buildWeatherSection(context),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    String locationDisplay = '';

    if (location != null) {
      locationDisplay = location!.displayName;
    } else {
      locationDisplay = weather.location;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 28,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationDisplay,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 0.07, maxSize: 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (location != null)
                  Text(
                    location!.locationDescription,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 18),
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection(BuildContext context) {
    return Card(
      elevation: 3,
      color: Color.fromRGBO(255, 255, 255, 0.85), // Semi-transparent card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Weather icon
                      Icon(
                        _getWeatherIcon(weather.condition),
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      // Weather condition text
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Conditions',
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(context, 0.05, maxSize: 20),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weather.condition,
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 18),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTemperature(context),
              ],
            ),
            const Divider(height: 32),
            _buildWeatherDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperature(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${weather.temperature.toStringAsFixed(1)}°C',
        style: TextStyle(
          fontSize: AppTheme.getResponsiveFontSize(context, 0.09, maxSize: 38),
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildWeatherDetails(BuildContext context) {
    return Column(
      children: [
        // Wind speed highlighted with a special container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.air,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wind Speed',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${weather.windSpeed.toStringAsFixed(1)} km/h',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 0.05, maxSize: 20),
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Other weather details
        _buildDetailRow(
          context,
          'Humidity',
          '${weather.humidity}%',
          Icons.water_drop,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          'Feels Like',
          '${weather.feelsLike.toStringAsFixed(1)}°C',
          Icons.thermostat,
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
          ),
        ),
      ],
    );
  }

  /// Returns the appropriate icon for the weather condition
  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains('sun') || condition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (condition.contains('part') && condition.contains('cloud')) {
      return Icons.wb_cloudy;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('rain')) {
      return Icons.grain;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return Icons.flash_on;
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return Icons.cloud_queue;
    } else {
      return Icons.cloud; // Default icon
    }
  }
}