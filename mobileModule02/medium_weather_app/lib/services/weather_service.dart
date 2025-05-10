import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';
import '../utils/logger_service.dart';
import '../models/geocoding/location.dart';
import '../services/geocoding_service.dart';

/// Service class for weather API integration using Open-Meteo API
class WeatherService {
  // Open-Meteo API base URLs
  static const String _weatherApiUrl = 'https://api.open-meteo.com/v1/forecast';

  // Weather variables to request from the API
  static const List<String> _weatherVariables = [
    'temperature_2m',
    'relative_humidity_2m',
    'apparent_temperature',
    'precipitation',
    'weather_code',
    'wind_speed_10m',
  ];

  /// Get current weather for a location
  Future<Weather> getCurrentWeather(String locationName) async {
    loggerService.i('Getting current weather for: $locationName');
    
    try {
      final weatherData = await getWeatherData(locationName);
      return weatherData.current;
    } catch (e) {
      loggerService.e('Error getting current weather', e);
      // Return mock data as fallback
      return Weather.mock();
    }
  }

  /// Get hourly forecast for today
  Future<List<HourlyForecast>> getHourlyForecast(String locationName) async {
    loggerService.i('Getting hourly forecast for: $locationName');
    
    try {
      final weatherData = await getWeatherData(locationName);
      
      // Filter only today's forecasts
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      return weatherData.hourly.where((forecast) {
        return forecast.time.isAfter(now) && forecast.time.isBefore(tomorrow);
      }).toList();
    } catch (e) {
      loggerService.e('Error getting hourly forecast', e);
      // Return mock data as fallback
      return List.generate(24, (index) => HourlyForecast.mock(index));
    }
  }

  /// Get daily forecast for the week
  Future<List<DailyForecast>> getDailyForecast(String locationName) async {
    loggerService.i('Getting daily forecast for: $locationName');
    
    try {
      final weatherData = await getWeatherData(locationName);
      return weatherData.daily;
    } catch (e) {
      loggerService.e('Error getting daily forecast', e);
      // Return mock data as fallback
      return List.generate(7, (index) => DailyForecast.mock(index));
    }
  }

  /// Get complete weather data for a location
  Future<WeatherData> getWeatherData(String locationName) async {
    loggerService.i('Getting complete weather data for: $locationName');

    try {
      // 1. Use GeocodingService to get location coordinates from the name (static method)
      final geocodingResponse = await GeocodingService.searchLocation(query: locationName);

      // Check if we have any results
      if (geocodingResponse.results.isNotEmpty) {
        // Get the first location
        final location = geocodingResponse.results[0];
        loggerService.d('Found location: ${location.name} at ${location.latitude}, ${location.longitude}');

        // 2. Call the _fetchWeatherByCoordinates method with these coordinates
        return await _fetchWeatherByCoordinates(
          location.latitude,
          location.longitude,
          location.displayName
        );
      } else {
        loggerService.w('No locations found for: $locationName');
        // Return mock data as fallback
        return WeatherData.mock();
      }
    } catch (e) {
      loggerService.e('Error getting weather data', e);
      // Return mock data as fallback
      loggerService.d('Returning mock weather data bundle');
      return WeatherData.mock();
    }
  }

  /// Get weather for the current location
  Future<WeatherData> getCurrentLocationWeather(double latitude, double longitude) async {
    return await getWeatherByCoordinates(latitude, longitude, 'Current Location');
  }

  /// Get weather data by coordinates - public method
  Future<WeatherData> getWeatherByCoordinates(double latitude, double longitude, String locationName) async {
    try {
      return await _fetchWeatherByCoordinates(
        latitude,
        longitude,
        locationName
      );
    } catch (e) {
      loggerService.e('Error getting weather for coordinates', e);
      // Return mock data as fallback
      return WeatherData.mock();
    }
  }
  
  /// Fetch weather data by coordinates
  Future<WeatherData> _fetchWeatherByCoordinates(
    double latitude, 
    double longitude,
    String locationName
  ) async {
    try {
      final Uri uri = Uri.parse(_weatherApiUrl).replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current': _weatherVariables.join(','),
          'hourly': _weatherVariables.join(','),
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum',
          'timezone': 'auto',
        },
      );
      
      loggerService.d('Weather API request: $uri');
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _parseWeatherData(data, locationName);
      } else {
        loggerService.e('Error fetching weather data: ${response.statusCode}', response.body);
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      loggerService.e('Exception fetching weather data', e);
      // Return mock data as fallback
      loggerService.d('Returning mock weather data bundle as fallback');
      return WeatherData.mock();
    }
  }
  
  /// Parse weather code to a human-readable condition
  String _getWeatherCondition(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 56:
      case 57:
        return 'Freezing Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  /// Get icon code based on weather code
  String _getIconCode(int weatherCode) {
    // Map Open-Meteo weather codes to icon codes
    // This is a simplified version - you can extend this to handle more cases
    if (weatherCode <= 1) {
      return '01d'; // Clear sky
    } else if (weatherCode <= 3) {
      return '02d'; // Partly cloudy
    } else if (weatherCode <= 48) {
      return '50d'; // Fog
    } else if (weatherCode <= 57) {
      return '09d'; // Drizzle
    } else if (weatherCode <= 67) {
      return '10d'; // Rain
    } else if (weatherCode <= 77) {
      return '13d'; // Snow
    } else if (weatherCode <= 82) {
      return '09d'; // Rain showers
    } else if (weatherCode <= 86) {
      return '13d'; // Snow showers
    } else {
      return '11d'; // Thunderstorm
    }
  }

  /// Parse the API response into WeatherData object
  WeatherData _parseWeatherData(Map<String, dynamic> data, String locationName) {
    try {
      // Parse current weather
      final currentData = data['current'];
      final currentWeatherCode = currentData['weather_code'];
      
      final Weather currentWeather = Weather(
        temperature: currentData['temperature_2m']?.toDouble() ?? 0.0,
        condition: _getWeatherCondition(currentWeatherCode),
        iconCode: _getIconCode(currentWeatherCode),
        feelsLike: currentData['apparent_temperature']?.toDouble() ?? 0.0,
        humidity: currentData['relative_humidity_2m']?.toInt() ?? 0,
        windSpeed: currentData['wind_speed_10m']?.toDouble() ?? 0.0,
        time: DateTime.parse(currentData['time']),
        location: locationName,
      );
      
      // Parse hourly forecast
      final List<HourlyForecast> hourlyForecasts = [];
      final hourlyTimes = data['hourly']['time'] as List;
      
      for (int i = 0; i < hourlyTimes.length; i++) {
        final weatherCode = data['hourly']['weather_code'][i];
        
        hourlyForecasts.add(HourlyForecast(
          time: DateTime.parse(hourlyTimes[i]),
          temperature: data['hourly']['temperature_2m'][i]?.toDouble() ?? 0.0,
          condition: _getWeatherCondition(weatherCode),
          iconCode: _getIconCode(weatherCode),
        ));
      }
      
      // Parse daily forecast
      final List<DailyForecast> dailyForecasts = [];
      final dailyTimes = data['daily']['time'] as List;
      
      for (int i = 0; i < dailyTimes.length; i++) {
        final weatherCode = data['daily']['weather_code'][i];
        
        dailyForecasts.add(DailyForecast(
          date: DateTime.parse(dailyTimes[i]),
          minTemp: data['daily']['temperature_2m_min'][i]?.toDouble() ?? 0.0,
          maxTemp: data['daily']['temperature_2m_max'][i]?.toDouble() ?? 0.0,
          condition: _getWeatherCondition(weatherCode),
          iconCode: _getIconCode(weatherCode),
          humidity: 0, // Not available in daily data
          windSpeed: 0.0, // Not available in daily data
        ));
      }
      
      return WeatherData(
        current: currentWeather,
        hourly: hourlyForecasts,
        daily: dailyForecasts,
      );
    } catch (e) {
      loggerService.e('Error parsing weather data', e);
      // Return mock data as fallback
      return WeatherData.mock();
    }
  }
}