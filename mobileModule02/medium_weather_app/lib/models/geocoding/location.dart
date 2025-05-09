/// Location model for geocoding API results
class Location {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1; // State or region
  final String? admin2; // County or sub-region
  final int? population;

  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.admin2,
    this.population,
  });

  /// Create a Location from JSON
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      country: json['country'],
      admin1: json['admin1'],
      admin2: json['admin2'],
      population: json['population'],
    );
  }

  /// Get a formatted display name
  String get displayName {
    String display = name;
    if (admin1 != null && admin1!.isNotEmpty) {
      display += ', $admin1';
    }
    if (country != null && country!.isNotEmpty) {
      display += ', $country';
    }
    return display;
  }

  /// Get a formatted location description
  String get locationDescription {
    // If we have region (admin1) and country, show both
    if (admin1 != null && admin1!.isNotEmpty && country != null && country!.isNotEmpty) {
      return '$admin1, $country';
    }
    // If we only have country, show that
    else if (country != null && country!.isNotEmpty) {
      return country!;
    }
    // Fallback if nothing else is available
    return 'Unknown location';
  }

  /// Convert to String representation
  @override
  String toString() {
    return displayName;
  }
}

/// Geocoding response containing a list of locations
class GeocodingResponse {
  final List<Location> results;
  final String? generationTimeMs;

  GeocodingResponse({
    required this.results,
    this.generationTimeMs,
  });

  /// Create a GeocodingResponse from JSON
  factory GeocodingResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonResults = json['results'] ?? [];
    final List<Location> locations = jsonResults
        .map((result) => Location.fromJson(result))
        .toList();

    return GeocodingResponse(
      results: locations,
      generationTimeMs: json['generationtime_ms']?.toString(),
    );
  }
}