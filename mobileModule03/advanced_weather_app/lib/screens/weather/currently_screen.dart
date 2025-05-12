import 'package:flutter/material.dart';
import '../../models/weather/weather.dart';
import '../../models/location/location.dart';
import '../../core/widgets/weather/location_info_card.dart';
import '../../core/widgets/weather/weather_condition_card.dart';

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
          LocationInfoCard(
            location: location,
            fallbackLocationName: weather.location,
          ),
          const SizedBox(height: 24),

          // Current weather info
          WeatherConditionCard(weather: weather),
        ],
      ),
    );
  }

}