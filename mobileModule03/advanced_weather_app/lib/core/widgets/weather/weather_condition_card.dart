import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/weather_icon_helper.dart';
import '../../../models/weather/weather.dart';

/// A card that displays current weather conditions
class WeatherConditionCard extends StatelessWidget {
  /// The weather data to display
  final Weather weather;

  const WeatherConditionCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
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
                        WeatherIconHelper.getWeatherIcon(weather.condition),
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
}