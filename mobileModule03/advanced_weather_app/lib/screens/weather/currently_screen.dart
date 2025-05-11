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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locationDisplay,
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 0.07, maxSize: 28),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (location != null)
          Text(
            location!.locationDescription,
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 18),
              color: Colors.grey[700],
            ),
          ),
      ],
    );
  }

  Widget _buildWeatherSection(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                    ),
                  ],
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
    return Text(
      '${weather.temperature.toStringAsFixed(1)}°C',
      style: TextStyle(
        fontSize: AppTheme.getResponsiveFontSize(context, 0.09, maxSize: 38),
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildWeatherDetails(BuildContext context) {
    return Column(
      children: [
        _buildDetailRow(
          context,
          'Wind',
          '${weather.windSpeed.toStringAsFixed(1)} km/h',
          Icons.air,
        ),
        const SizedBox(height: 16),
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
}