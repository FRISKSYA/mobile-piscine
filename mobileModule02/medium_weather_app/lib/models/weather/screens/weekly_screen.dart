import 'package:flutter/material.dart';
import '../models/forecast.dart';
import '../config/theme.dart';
import '../models/geocoding/location.dart';
import 'package:intl/intl.dart';

/// Screen to display weekly forecast
class WeeklyScreen extends StatelessWidget {
  final List<DailyForecast> dailyForecasts;
  final Location? location;

  const WeeklyScreen({
    super.key,
    required this.dailyForecasts,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location header
        _buildLocationHeader(context),

        // Daily forecast list
        Expanded(
          child: _buildDailyForecastList(context),
        ),
      ],
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    String locationDisplay = location?.displayName ?? 'Weekly Forecast';

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
            '7-Day Forecast',
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

  Widget _buildDailyForecastList(BuildContext context) {
    if (dailyForecasts.isEmpty) {
      return const Center(
        child: Text('No weekly forecast data available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: dailyForecasts.length,
      itemBuilder: (context, index) {
        final forecast = dailyForecasts[index];
        return _buildDailyForecastItem(context, forecast, index);
      },
    );
  }

  Widget _buildDailyForecastItem(BuildContext context, DailyForecast forecast, int index) {
    final dateFormat = DateFormat('E, MMM d'); // Day of week, Month Day (e.g., Mon, Jan 15)
    final isToday = index == 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Date
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Today' : dateFormat.format(forecast.date),
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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

            // Min-Max Temperature
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${forecast.maxTemp.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${forecast.minTemp.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 0.035, maxSize: 14),
                    color: Colors.grey[600],
                  ),
                ),
              ],
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
      return Icons.cloud;
    }
  }
}