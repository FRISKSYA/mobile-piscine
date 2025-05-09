import 'package:flutter/material.dart';
import '../models/forecast.dart';
import '../config/theme.dart';

/// Screen to display today's hourly forecast
class TodayScreen extends StatelessWidget {
  final List<HourlyForecast> hourlyForecasts;

  const TodayScreen({
    super.key,
    required this.hourlyForecasts,
  });

  @override
  Widget build(BuildContext context) {
    // For now, we just return the placeholder content
    // This will be expanded in future exercises to display actual forecast data
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.today,
            size: AppTheme.getResponsiveIconSize(context, 0.15, maxSize: 80),
            color: Theme.of(context).colorScheme.primary.withAlpha(179), // 0.7 * 255 = 179
          ),
          const SizedBox(height: 16),
          Text(
            'Today\'s Forecast',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 0.06, maxSize: 32),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hourly forecast will be shown here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}