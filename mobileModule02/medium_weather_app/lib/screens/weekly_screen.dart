import 'package:flutter/material.dart';
import '../models/forecast.dart';
import '../config/theme.dart';

/// Screen to display weekly forecast
class WeeklyScreen extends StatelessWidget {
  final List<DailyForecast> dailyForecasts;

  const WeeklyScreen({
    super.key,
    required this.dailyForecasts,
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
            Icons.calendar_view_week,
            size: AppTheme.getResponsiveIconSize(context, 0.15, maxSize: 80),
            color: Theme.of(context).colorScheme.primary.withAlpha(179), // 0.7 * 255 = 179
          ),
          const SizedBox(height: 16),
          Text(
            'Weekly Forecast',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 0.06, maxSize: 32),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daily forecast will be shown here',
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