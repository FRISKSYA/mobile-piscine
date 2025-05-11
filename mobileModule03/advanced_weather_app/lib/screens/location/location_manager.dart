import 'package:geolocator/geolocator.dart';
import '../../models/location/location_service.dart';
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
    // Check if already loading location to prevent multiple requests
    if (isLoadingLocation) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location request already in progress, please wait...')),
        );
      }
      return;
    }

    // Show loading state
    isLoadingLocation = true;
    isUsingGeolocation = true;

    // Show a snackbar to indicate that we're getting the current location
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Getting current location...')),
      );
    }

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

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied. Please enable it in app settings.'),
                duration: Duration(seconds: 4),
              ),
            );
          }
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

      // Check for common error types and provide more user-friendly messages
      if (e.toString().contains('Permission')) {
        currentLocation = 'Location permission denied';
        locationPermissionDenied = true;

        // Show permission error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Please enable it in app settings.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else if (e.toString().contains('location service is disabled') ||
                e.toString().contains('services are disabled')) {
        currentLocation = 'Location services disabled';

        // Show location services disabled message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable location in your device settings.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else if (e.toString().contains('already running')) {
        currentLocation = 'Location request in progress';

        // Already showing message in the guard clause, no need to show again
      } else {
        // Set a more informative message for network errors
        currentLocation = 'Network error';

        // Log the detailed error
        loggerService.e('Error getting location', e);

        // Show a more user-friendly message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network error. Please check your internet connection and try again.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }
}