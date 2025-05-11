import '../weather/weather.dart';

/// Model class for daily forecast data
class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  // Factory constructor to create DailyForecast from API JSON
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    // This will be implemented when we connect to an actual API
    // For now, it's a placeholder
    return DailyForecast(
      date: DateTime.now(),
      minTemp: 0.0,
      maxTemp: 0.0,
      condition: '',
      iconCode: '',
      humidity: 0,
      windSpeed: 0.0,
    );
  }

}

/// Model class for hourly forecast data
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;
  final String iconCode;
  final double windSpeed;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    this.windSpeed = 0.0,
  });

  // Factory constructor to create HourlyForecast from API JSON
  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    // This will be implemented when we connect to an actual API
    // For now, it's a placeholder
    return HourlyForecast(
      time: DateTime.now(),
      temperature: 0.0,
      condition: '',
      iconCode: '',
      windSpeed: 0.0,
    );
  }

}

/// Wrapper class that contains all weather data
class WeatherData {
  final Weather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });

}