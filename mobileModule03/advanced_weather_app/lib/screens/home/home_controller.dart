import 'package:flutter/material.dart';
import '../../models/forecast/forecast.dart';
import '../../models/location/location.dart';
import '../../models/weather/weather_service.dart';
import '../../core/utils/logger_service.dart';
import '../location/location_manager.dart';
import '../search/search_manager.dart';

class HomeController {
  // Managers
  final LocationManager locationManager = LocationManager();
  final SearchManager searchManager = SearchManager();
  final WeatherService weatherService = WeatherService();

  // Controllers
  late TabController tabController;
  final TextEditingController searchController = TextEditingController();

  // Weather data
  WeatherData? weatherData;
  bool isLoadingWeather = false;

  // Selected location
  Location? selectedLocation;

  // Error states
  bool hasError = false;
  String errorMessage = '';
  bool isLocationNotFound = false;
  bool isConnectionError = false;

  // Initialize the view model
  void init(TickerProvider vsync) {
    tabController = TabController(length: 3, vsync: vsync);
    // Set default tab to "Currently" (index 0)
    tabController.index = 0;

    // Add tab controller listener to check connection state on tab change
    tabController.addListener(() {
      // Clear search-related errors when changing tabs
      if (isLocationNotFound) {
        isLocationNotFound = false;

        // If no connection error exists, clear the error banner completely
        if (!weatherService.hasConnectionError) {
          hasError = false;
          errorMessage = '';
        }
      }

      // Check if we need to show connection errors
      checkConnectionState();
    });

    // Initialize with default weather data (Tokyo)
    _loadDefaultWeatherData();

    // Add listener to search controller
    searchController.addListener(_onSearchChanged);

    // Request location permission on startup
    _requestLocationPermissionOnStartup();
  }

  // Request location permission on app startup
  Future<void> _requestLocationPermissionOnStartup() async {
    try {
      // First check current permission status
      bool hasPermission = await locationManager.checkLocationPermission();

      // If permission is not granted, request it
      if (!hasPermission) {
        await locationManager.requestLocationPermission();
      }
    } catch (e) {
      loggerService.e('Error requesting location permission on startup', e);
    }
  }

  // Load default weather data for initial display
  Future<void> _loadDefaultWeatherData() async {
    isLoadingWeather = true;
    try {
      // Default to Tokyo if no location is selected
      final result = await weatherService.getWeatherData('Tokyo');
      weatherData = result.data;
      loggerService.i('Loaded default weather data');
    } catch (e) {
      loggerService.e('Error loading default weather data', e);
      // Return null on error
      weatherData = null;
    } finally {
      isLoadingWeather = false;
    }
  }

  // Handle search input changes
  void _onSearchChanged() {
    searchManager.onSearchInputChanged(
      searchController.text,
      searchManager.searchLocation,
    );
  }

  // Create a subtitle for tab content
  String getTabSubtitle(String tabName) {
    return locationManager.currentLocation.isEmpty
        ? 'This is the $tabName tab content'
        : locationManager.currentLocation;
  }

  // Reset error states
  void clearError() {
    // Always clear location not found errors as they should not persist
    isLocationNotFound = false;

    // Clear connection errors only if the global connection state is restored
    if (!weatherService.hasConnectionError) {
      hasError = false;
      errorMessage = '';
      isConnectionError = false;
    } else {
      // Keep connection error visible
      hasError = true;
      isConnectionError = true;
      errorMessage = weatherService.connectionErrorMessage;
    }
  }

  // Check connection state and update UI accordingly
  void checkConnectionState() {
    // Update the UI to reflect the current global connection state
    if (weatherService.hasConnectionError) {
      // Only update if we don't have a location not found error
      // This ensures location not found errors remain visible and aren't
      // immediately replaced by connection errors
      if (!isLocationNotFound) {
        hasError = true;
        isConnectionError = true;
        errorMessage = weatherService.connectionErrorMessage;
      }
    } else if (isConnectionError) {
      // Clear connection error if it was restored
      isConnectionError = false;
      // Only clear the error banner if no other errors are present
      if (!isLocationNotFound) {
        hasError = false;
        errorMessage = '';
      }
    }
  }

  // Get the current location
  Future<void> getCurrentLocation(BuildContext context) async {
    isLoadingWeather = true;
    clearError(); // Reset error states when starting a new request

    await locationManager.getCurrentLocation(context);

    // Check if context is still valid after the async operation
    if (!context.mounted) {
      isLoadingWeather = false;
      return;
    }

    // Reset selected location when using device location
    selectedLocation = null;

    // Check if we encountered a network error during location fetch
    if (locationManager.currentLocation == 'Network error') {
      hasError = true;
      isConnectionError = true;
      errorMessage = 'Network error. Please check your internet connection and try again.';
      isLoadingWeather = false;
      return;
    }

    // Get weather for the current location if permission is granted
    if (!locationManager.locationPermissionDenied && locationManager.isUsingGeolocation) {
      try {
        // Parse the coordinates from the coordinatesText
        final coordsText = locationManager.coordinatesText;
        final latLongMatch = RegExp(r'Latitude: ([\d.-]+), Longitude: ([\d.-]+)').firstMatch(coordsText);

        if (latLongMatch != null) {
          final latitude = double.parse(latLongMatch.group(1)!);
          final longitude = double.parse(latLongMatch.group(2)!);

          // Get weather data for current location
          final result = await weatherService.getCurrentLocationWeather(latitude, longitude);
          weatherData = result.data;

          // Show error message if there's a connection issue
          if (result.connectionError) {
            hasError = true;
            isConnectionError = true;
            errorMessage = result.errorMessage;

            // Error banner is already displayed, no need for additional SnackBar
          } else {
            clearError(); // Clear any previous errors on success
            loggerService.i('Loaded weather data for current location');
          }
        }
      } catch (e) {
        loggerService.e('Error getting weather for current location', e);
        weatherData = null;

        hasError = true;
        isConnectionError = true;
        errorMessage = 'Error getting weather data. Please try again later.';

        // Error banner is already displayed, no need for additional SnackBar
      }
    }

    isLoadingWeather = false;
  }

  // Handle location selection from search results
  Future<void> onLocationSelected(Location location, BuildContext context) async {
    isLoadingWeather = true;
    clearError(); // Reset error states

    // Update location info
    locationManager.currentLocation = location.name;
    locationManager.isUsingGeolocation = false;
    locationManager.coordinatesText = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';

    // Check if context is still valid
    if (!context.mounted) {
      isLoadingWeather = false;
      return;
    }

    // Store the selected location object to display in weather screens
    selectedLocation = location;

    // Get weather data for the selected location
    try {
      // Use the location coordinates directly since we already have them
      final result = await weatherService.getWeatherByCoordinates(
        location.latitude,
        location.longitude,
        location.displayName
      );

      weatherData = result.data;

      // Show error message if there's a connection issue
      if (result.connectionError) {
        hasError = true;
        isConnectionError = true;
        errorMessage = result.errorMessage;

        // Error banner is already displayed, no need for additional SnackBar
      } else {
        clearError(); // Clear any previous errors
        loggerService.i('Loaded weather data for ${location.name}');
      }
    } catch (e) {
      loggerService.e('Error getting weather for location ${location.name}', e);
      weatherData = null;

      hasError = true;
      isConnectionError = true;
      errorMessage = 'Error getting weather data for ${location.name}. Please try again later.';

      // Error banner is already displayed, no need for additional SnackBar
    }

    if (context.mounted) {
      searchManager.onLocationSelected(location, context, searchController);
    }
    isLoadingWeather = false;
  }

  // Handle search submission
  Future<void> onSearchSubmitted(String location, BuildContext context) async {
    if (location.isEmpty) return;

    isLoadingWeather = true;
    clearError(); // Reset error states
    locationManager.currentLocation = location;
    locationManager.isUsingGeolocation = false;

    // Check if context is still valid
    if (!context.mounted) {
      isLoadingWeather = false;
      return;
    }

    // Get weather data for the submitted location
    try {
      final result = await weatherService.getWeatherData(location);
      weatherData = result.data;

      // Check if the location was found
      if (!result.locationFound) {
        hasError = true;
        isLocationNotFound = true;
        errorMessage = 'City "$location" not found. Please enter a valid city name.';
        // Error banner is already displayed, no need for additional SnackBar
      } else if (result.connectionError) {
        // Show connection error with retry option
        hasError = true;
        isConnectionError = true;
        errorMessage = result.errorMessage;

        // Error banner is already displayed, no need for additional SnackBar
      } else {
        clearError(); // Clear any previous errors
        loggerService.i('Loaded weather data for search query: $location');
      }

      // Reset selected location since this is a direct search
      selectedLocation = null;
    } catch (e) {
      loggerService.e('Error getting weather for search query: $location', e);
      weatherData = null;

      hasError = true;
      isConnectionError = true;
      errorMessage = 'Error getting weather data. Please try again later.';

      // Error banner is already displayed, no need for additional SnackBar
    }

    if (context.mounted) {
      searchManager.onSearchSubmitted(location, context, searchController);
    }
    isLoadingWeather = false;
  }

  // Clean up resources
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    searchManager.dispose();
  }
}