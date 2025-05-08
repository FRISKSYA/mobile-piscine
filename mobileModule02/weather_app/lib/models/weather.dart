/// Model class for weather data
class Weather {
  final double temperature;
  final String condition;
  final String iconCode;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final DateTime time;
  final String location;

  Weather({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.time,
    required this.location,
  });

  // Factory constructor to create Weather from API JSON
  factory Weather.fromJson(Map<String, dynamic> json) {
    // This will be implemented when we connect to an actual API
    // For now, it's a placeholder
    return Weather(
      temperature: 0.0,
      condition: '',
      iconCode: '',
      feelsLike: 0.0,
      humidity: 0,
      windSpeed: 0.0,
      time: DateTime.now(),
      location: '',
    );
  }

  // Create a mock weather object for testing
  factory Weather.mock() {
    return Weather(
      temperature: 22.5,
      condition: 'Cloudy',
      iconCode: '03d',
      feelsLike: 24.0,
      humidity: 65,
      windSpeed: 5.2,
      time: DateTime.now(),
      location: 'Tokyo, Japan',
    );
  }
}