import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/location.dart';
import '../../core/utils/logger_service.dart';

/// Service to handle geocoding requests
class GeocodingService {
  // Open-Meteo API base URL for geocoding
  static const String baseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  
  /// Search for locations by name
  /// 
  /// [query] - The location name to search for
  /// [language] - Optional language for the results (e.g., 'en', 'ja', 'fr')
  /// [limit] - Maximum number of results to return
  static Future<GeocodingResponse> searchLocation({
    required String query,
    String language = 'en',
    int limit = 10,
  }) async {
    if (query.isEmpty) {
      return GeocodingResponse(results: []);
    }
    
    try {
      // Build the URL with query parameters
      final Uri uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'name': query,
          'count': limit.toString(),
          'language': language,
          'format': 'json',
        },
      );

      loggerService.d('Geocoding API request: $uri');
      
      // Make the HTTP request
      final response = await http.get(uri);
      
      // Check for successful response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return GeocodingResponse.fromJson(data);
      } else {
        // Handle error cases
        loggerService.e('Error searching locations: ${response.statusCode}', response.body);
        return GeocodingResponse(results: []);
      }
    } catch (e) {
      // Handle exceptions
      loggerService.e('Exception searching locations:', e);
      return GeocodingResponse(results: []);
    }
  }
}