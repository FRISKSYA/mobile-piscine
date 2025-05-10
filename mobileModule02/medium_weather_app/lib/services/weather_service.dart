import '../models/weather.dart';
import '../models/forecast.dart';
import '../utils/logger_service.dart';

/// Service class for weather API integration
class WeatherService {
  // This is a placeholder for future API integration
  // In future exercises, this will be implemented to make actual API calls

  /// Get current weather for a location
  Future<Weather> getCurrentWeather(String location) async {
    loggerService.i('Getting current weather for: $location');

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    loggerService.d('Returning mock weather data');
    return Weather.mock();
  }

  /// Get hourly forecast for today
  Future<List<HourlyForecast>> getHourlyForecast(String location) async {
    loggerService.i('Getting hourly forecast for: $location');

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    loggerService.d('Returning mock hourly forecast data');
    return List.generate(24, (index) => HourlyForecast.mock(index));
  }

  /// Get daily forecast for the week
  Future<List<DailyForecast>> getDailyForecast(String location) async {
    loggerService.i('Getting daily forecast for: $location');

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    loggerService.d('Returning mock daily forecast data');
    return List.generate(7, (index) => DailyForecast.mock(index));
  }

  /// Get complete weather data for a location
  Future<WeatherData> getWeatherData(String location) async {
    loggerService.i('Getting complete weather data for: $location');

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    loggerService.d('Returning mock weather data bundle');
    return WeatherData.mock();
  }
}