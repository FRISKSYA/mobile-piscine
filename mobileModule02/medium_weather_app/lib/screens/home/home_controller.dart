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

    // Initialize with default weather data (Tokyo)
    _loadDefaultWeatherData();

    // Add listener to search controller
    searchController.addListener(_onSearchChanged);

    // Check for location permission on startup
    locationManager.checkLocationPermission();
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
      // Fall back to mock data if API fails
      weatherData = WeatherData.mock();
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
    hasError = false;
    errorMessage = '';
    isLocationNotFound = false;
    isConnectionError = false;
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
        weatherData = WeatherData.mock();

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
      weatherData = WeatherData.mock();

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
      weatherData = WeatherData.mock();

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