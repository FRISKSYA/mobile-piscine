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

  // Create a mock forecast for testing
  factory DailyForecast.mock(int daysFromNow) {
    return DailyForecast(
      date: DateTime.now().add(Duration(days: daysFromNow)),
      minTemp: 18.0 + daysFromNow,
      maxTemp: 26.0 + daysFromNow,
      condition: 'Partly Cloudy',
      iconCode: '02d',
      humidity: 60,
      windSpeed: 4.5,
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

  // Create a mock hourly forecast for testing
  factory HourlyForecast.mock(int hoursFromNow) {
    return HourlyForecast(
      time: DateTime.now().add(Duration(hours: hoursFromNow)),
      temperature: 22.0 + (hoursFromNow % 5),
      condition: 'Sunny',
      iconCode: '01d',
      windSpeed: 3.0 + (hoursFromNow % 4),
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

  // Create mock weather data for testing
  factory WeatherData.mock() {
    return WeatherData(
      current: Weather.mock(),
      hourly: List.generate(24, (index) => HourlyForecast.mock(index)),
      daily: List.generate(7, (index) => DailyForecast.mock(index)),
    );
  }
}