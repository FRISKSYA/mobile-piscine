import 'package:geolocator/geolocator.dart';

/// A service to handle location-related operations
class LocationService {
  /// Get the current location of the device
  /// 
  /// Returns a [Future<Position>] if successful, or throws an exception if
  /// - Location services are disabled
  /// - Permission is denied
  /// - Permission is denied forever
  Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check for location permission
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    } 

    // Get the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Check if location permission is granted
  /// 
  /// Returns a [Future<bool>] that completes with true if permission is granted
  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Request location permission
  /// 
  /// Returns a [Future<bool>] that completes with true if permission is granted
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Format a Position object into a human-readable string
  /// 
  /// Returns a string in the format "Latitude: XX.XXXX, Longitude: YY.YYYY"
  String formatPosition(Position position) {
    return 'Latitude: ${position.latitude.toStringAsFixed(4)}, '
           'Longitude: ${position.longitude.toStringAsFixed(4)}';
  }
}