import 'package:flutter/material.dart';
import '../../models/forecast/forecast.dart';
import '../../../core/theme/app_theme.dart';
import '../../models/location/location.dart';
import 'package:intl/intl.dart';

/// Screen to display today's hourly forecast
class TodayScreen extends StatelessWidget {
  final List<HourlyForecast>? hourlyForecasts;
  final Location? location;

  const TodayScreen({
    super.key,
    required this.hourlyForecasts,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location header
        _buildLocationHeader(context),

        // Hourly forecast list
        Expanded(
          child: _buildHourlyForecastList(context),
        ),
      ],
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    String locationDisplay = location?.displayName ?? 'Today\'s Forecast';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locationDisplay,
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 0.06, maxSize: 24),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (location != null)
            Text(
              location!.locationDescription,
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                color: Colors.grey[700],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 0.05, maxSize: 20),
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastList(BuildContext context) {
    if (hourlyForecasts == null || hourlyForecasts!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hourly forecast data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: hourlyForecasts!.length,
      itemBuilder: (context, index) {
        final forecast = hourlyForecasts![index];
        return _buildHourlyForecastItem(context, forecast);
      },
    );
  }

  Widget _buildHourlyForecastItem(BuildContext context, HourlyForecast forecast) {
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Time
                SizedBox(
                  width: 60,
                  child: Text(
                    timeFormat.format(forecast.time),
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Weather condition icon and text
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        _getWeatherIcon(forecast.condition),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          forecast.condition,
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 0.035, maxSize: 14),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Temperature
                Text(
                  '${forecast.temperature.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            // Wind speed row
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 60.0),
              child: Row(
                children: [
                  Icon(
                    Icons.air,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Wind: ${forecast.windSpeed.toStringAsFixed(1)} km/h',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 0.035, maxSize: 14),
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains('sun') || condition.contains('clear')) {
      return Icons.wb_sunny;
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
      return Icons.cloud;
    }
  }
}