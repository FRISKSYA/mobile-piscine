import 'dart:convert';
import 'package:http/http.dart' as http;
import './weather.dart';
import '../forecast/forecast.dart';
import '../../core/utils/logger_service.dart';
import '../location/geocoding_service.dart';

/// Result class that includes weather data and error information
class WeatherResult {
  final WeatherData? data;
  final bool locationFound;
  final bool connectionError;
  final String errorMessage;

  WeatherResult({
    this.data,
    this.locationFound = true,
    this.connectionError = false,
    this.errorMessage = '',
  });
}

/// Service class for weather API integration using Open-Meteo API
class WeatherService {
  // Open-Meteo API base URLs
  static const String _weatherApiUrl = 'https://api.open-meteo.com/v1/forecast';

  // Global connection error state
  bool hasConnectionError = false;
  String connectionErrorMessage = '';

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
  Future<Weather?> getCurrentWeather(String locationName) async {
    loggerService.i('Getting current weather for: $locationName');

    try {
      final result = await getWeatherData(locationName);
      if (result.data == null) return null;
      return result.data!.current;
    } catch (e) {
      loggerService.e('Error getting current weather', e);
      // Return null on error
      return null;
    }
  }

  /// Get hourly forecast for today
  Future<List<HourlyForecast>?> getHourlyForecast(String locationName) async {
    loggerService.i('Getting hourly forecast for: $locationName');

    try {
      final result = await getWeatherData(locationName);
      if (result.data == null || result.data?.hourly == null) return null;

      // Filter only today's forecasts
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      return result.data!.hourly.where((forecast) {
        return forecast.time.isAfter(now) && forecast.time.isBefore(tomorrow);
      }).toList();
    } catch (e) {
      loggerService.e('Error getting hourly forecast', e);
      // Return null on error
      return null;
    }
  }

  /// Get daily forecast for the week
  Future<List<DailyForecast>?> getDailyForecast(String locationName) async {
    loggerService.i('Getting daily forecast for: $locationName');

    try {
      final result = await getWeatherData(locationName);
      if (result.data == null || result.data?.daily == null) return null;
      return result.data!.daily;
    } catch (e) {
      loggerService.e('Error getting daily forecast', e);
      // Return null on error
      return null;
    }
  }

  /// Get complete weather data for a location
  Future<WeatherResult> getWeatherData(String locationName) async {
    loggerService.i('Getting complete weather data for: $locationName');

    try {
      // 1. Use GeocodingService to get location coordinates from the name (static method)
      final geocodingResponse = await GeocodingService.searchLocation(query: locationName);

      // Check if there was a connection error with the geocoding service
      if (geocodingResponse.connectionError || GeocodingService.hasConnectionError) {
        // Use the static connection error information from GeocodingService
        hasConnectionError = true;
        connectionErrorMessage = GeocodingService.connectionErrorMessage.isNotEmpty
            ? GeocodingService.connectionErrorMessage
            : 'Cannot connect to location service. Check your internet connection.';

        return WeatherResult(
          data: null,
          locationFound: false,
          connectionError: true,
          errorMessage: connectionErrorMessage
        );
      }

      // Check if we have any results
      if (geocodingResponse.results.isNotEmpty) {
        // Get the first location
        final location = geocodingResponse.results[0];
        loggerService.d('Found location: ${location.name} at ${location.latitude}, ${location.longitude}');

        try {
          // 2. Call the _fetchWeatherByCoordinates method with these coordinates
          final weatherData = await _fetchWeatherByCoordinates(
            location.latitude,
            location.longitude,
            location.displayName
          );
          // Clear connection error state on success
          hasConnectionError = false;
          connectionErrorMessage = '';
          return WeatherResult(
            data: weatherData,
            locationFound: true,
            connectionError: false,
          );
        } catch (e) {
          // API connection error
          loggerService.e('Error fetching weather data', e);
          // Set global connection error state
          hasConnectionError = true;
          connectionErrorMessage = 'Cannot connect to weather service. Check your internet connection.';
          return WeatherResult(
            data: null,
            locationFound: true,
            connectionError: true,
            errorMessage: connectionErrorMessage
          );
        }
      } else {
        loggerService.w('No locations found for: $locationName');
        // Not a connection error, so don't set the global connection error state
        // City not found error should not persist across screens
        return WeatherResult(
          data: null,
          locationFound: false,
          errorMessage: 'City "$locationName" not found'
        );
      }
    } catch (e) {
      loggerService.e('Error getting weather data', e);
      // General error or connection error to Geocoding API
      // Set global connection error state
      hasConnectionError = true;
      connectionErrorMessage = 'Cannot connect to location service. Check your internet connection.';
      return WeatherResult(
        data: null,
        locationFound: false,
        connectionError: true,
        errorMessage: connectionErrorMessage
      );
    }
  }

  /// Get weather for the current location
  Future<WeatherResult> getCurrentLocationWeather(double latitude, double longitude) async {
    return await getWeatherByCoordinates(latitude, longitude, 'Current Location');
  }

  /// Get weather data by coordinates - public method
  Future<WeatherResult> getWeatherByCoordinates(double latitude, double longitude, String locationName) async {
    try {
      final weatherData = await _fetchWeatherByCoordinates(
        latitude,
        longitude,
        locationName
      );
      // Clear connection error state on success
      hasConnectionError = false;
      connectionErrorMessage = '';
      return WeatherResult(
        data: weatherData,
        locationFound: true,
        connectionError: false,
      );
    } catch (e) {
      loggerService.e('Error getting weather for coordinates', e);
      // Set global connection error state
      hasConnectionError = true;
      connectionErrorMessage = 'Cannot connect to weather service. Check your internet connection.';
      // Return null data on error
      return WeatherResult(
        data: null,
        locationFound: true,
        connectionError: true,
        errorMessage: connectionErrorMessage
      );
    }
  }
  
  /// Fetch weather data by coordinates
  Future<WeatherData?> _fetchWeatherByCoordinates(
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
      // Return null on error
      loggerService.d('Returning null due to error');
      return null;
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
  WeatherData? _parseWeatherData(Map<String, dynamic> data, String locationName) {
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
          windSpeed: data['hourly']['wind_speed_10m']?[i]?.toDouble() ?? 0.0,
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
      // Return null on error
      return null;
    }
  }
}