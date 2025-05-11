import 'dart:convert';
import 'package:http/http.dart' as http;
import './location.dart';
import '../../core/utils/logger_service.dart';

/// Service to handle geocoding requests
class GeocodingService {
  // Open-Meteo API base URL for geocoding
  static const String baseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  // Track connection error state
  static bool hasConnectionError = false;
  static String connectionErrorMessage = '';

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

      // If we got a response, clear the connection error state
      hasConnectionError = false;
      connectionErrorMessage = '';

      // Check for successful response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return GeocodingResponse.fromJson(data);
      } else {
        // Handle error cases (server errors, not connection issues)
        loggerService.e('Error searching locations: ${response.statusCode}', response.body);
        return GeocodingResponse(results: []);
      }
    } catch (e) {
      // Check for connection/network errors (SocketException, etc.)
      loggerService.e('Exception searching locations:', e);

      // Set connection error state
      hasConnectionError = true;
      connectionErrorMessage = 'Cannot connect to location service. Check your internet connection.';

      // Return empty result
      return GeocodingResponse(results: [], connectionError: true);
    }
  }
}