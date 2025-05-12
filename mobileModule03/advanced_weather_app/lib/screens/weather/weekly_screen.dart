import 'package:flutter/material.dart';
import '../../models/forecast/forecast.dart';
import '../../core/theme/app_theme.dart';
import '../../models/location/location.dart';
import 'package:intl/intl.dart';
import './weekly_forecast_chart.dart';

/// Screen to display weekly forecast
class WeeklyScreen extends StatelessWidget {
  final List<DailyForecast>? dailyForecasts;
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

        // Temperature chart
        if (dailyForecasts != null && dailyForecasts!.isNotEmpty)
          _buildTemperatureChart(context),

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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locationDisplay,
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 0.06, maxSize: 24),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (location != null)
              Text(
                location!.locationDescription,
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                  color: Colors.black54,
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
      ),
    );
  }

  Widget _buildTemperatureChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
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
              Text(
                'Temperature Forecast',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 0.05, maxSize: 18),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: WeeklyForecastChart(
                  dailyForecasts: dailyForecasts!,
                  minColor: Colors.blue,
                  maxColor: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Max Temp', Colors.red),
                  const SizedBox(width: 24),
                  _buildLegendItem('Min Temp', Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastList(BuildContext context) {
    if (dailyForecasts == null || dailyForecasts!.isEmpty) {
      return Center(
        child: Card(
          elevation: 3,
          color: Color.fromRGBO(255, 255, 255, 0.85), // Semi-transparent card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No weekly forecast data available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: dailyForecasts!.length,
      itemBuilder: (context, index) {
        final forecast = dailyForecasts![index];
        return _buildDailyForecastItem(context, forecast, index);
      },
    );
  }

  Widget _buildDailyForecastItem(BuildContext context, DailyForecast forecast, int index) {
    final dateFormat = DateFormat('E, MMM d'); // Day of week, Month Day (e.g., Mon, Jan 15)
    final isToday = index == 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: Color.fromRGBO(255, 255, 255, 0.85), // Semi-transparent card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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