import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'package:flutter/material.dart';
import '../../core/utils/logger_service.dart';

class LocationManager {
  final LocationService _locationService = LocationService();
  
  // Location state
  String currentLocation = '';
  bool isUsingGeolocation = false;
  String coordinatesText = '';
  bool isLoadingLocation = false;
  bool locationPermissionDenied = false;

  // Check if location permission is granted
  Future<bool> checkLocationPermission() async {
    try {
      bool hasPermission = await _locationService.isLocationPermissionGranted();
      locationPermissionDenied = !hasPermission;
      return hasPermission;
    } catch (e) {
      loggerService.e('Error checking location permission: $e');
      return false;
    }
  }

  // Get current location
  Future<void> getCurrentLocation(BuildContext context) async {
    // Show loading state
    isLoadingLocation = true;
    isUsingGeolocation = true;
    
    // Show a snackbar to indicate that we're getting the current location
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Getting current location...')),
    );
    
    try {
      // Check if location permission is granted
      bool hasPermission = await _locationService.isLocationPermissionGranted();
      
      if (!hasPermission) {
        // Request permission if not granted
        hasPermission = await _locationService.requestLocationPermission();
        
        if (!hasPermission) {
          locationPermissionDenied = true;
          isLoadingLocation = false;
          coordinatesText = '';
          currentLocation = 'Location permission denied';
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Please enable it in app settings.'),
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
      }
      
      // Get the current position
      Position position = await _locationService.getCurrentLocation();
      
      // Format the position for display
      String formattedPosition = _locationService.formatPosition(position);
      
      // Update the state with the current location
      coordinatesText = formattedPosition;
      currentLocation = 'Current Location';
      isLoadingLocation = false;
      locationPermissionDenied = false;
    } catch (e) {
      isLoadingLocation = false;
      coordinatesText = '';
      currentLocation = 'Error getting location';
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    }
  }
}