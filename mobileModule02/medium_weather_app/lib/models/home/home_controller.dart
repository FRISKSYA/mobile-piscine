import 'package:flutter/material.dart';
import '../common/forecast.dart';
import '../common/location.dart';
import '../weather/weather_service.dart';
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

  // Get the current location
  Future<void> getCurrentLocation(BuildContext context) async {
    isLoadingWeather = true;

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
          if (result.connectionError && context.mounted) {
            _showConnectionError(
              context,
              result.errorMessage,
              () => getCurrentLocation(context)
            );
          } else {
            loggerService.i('Loaded weather data for current location');
          }
        }
      } catch (e) {
        loggerService.e('Error getting weather for current location', e);
        weatherData = WeatherData.mock();

        if (context.mounted) {
          _showConnectionError(
            context,
            'Error getting weather data. Please try again later.',
            () => getCurrentLocation(context)
          );
        }
      }
    }

    isLoadingWeather = false;
  }

  // Handle location selection from search results
  Future<void> onLocationSelected(Location location, BuildContext context) async {
    isLoadingWeather = true;

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
      if (result.connectionError && context.mounted) {
        _showConnectionError(
          context,
          result.errorMessage,
          () => onLocationSelected(location, context)
        );
      } else {
        loggerService.i('Loaded weather data for ${location.name}');
      }
    } catch (e) {
      loggerService.e('Error getting weather for location ${location.name}', e);
      weatherData = WeatherData.mock();

      if (context.mounted) {
        _showConnectionError(
          context,
          'Error getting weather data for ${location.name}. Please try again later.',
          () => onLocationSelected(location, context)
        );
      }
    }

    if (context.mounted) {
      searchManager.onLocationSelected(location, context, searchController);
    }
    isLoadingWeather = false;
  }

  // Helper method to show connection error message with retry option
  void _showConnectionError(BuildContext context, String errorMessage, Function() retryAction) {
    // Already contains a context.mounted check - no need to add another one
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: retryAction,
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  // Handle search submission
  Future<void> onSearchSubmitted(String location, BuildContext context) async {
    if (location.isEmpty) return;

    isLoadingWeather = true;
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('City "$location" not found. Please enter a valid city name.'),
              duration: const Duration(seconds: 8),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {},
              ),
            ),
          );
        }
      } else if (result.connectionError) {
        // Show connection error with retry option
        if (context.mounted) {
          _showConnectionError(
            context,
            result.errorMessage,
            () => onSearchSubmitted(location, context)
          );
        }
      } else {
        loggerService.i('Loaded weather data for search query: $location');
      }

      // Reset selected location since this is a direct search
      selectedLocation = null;
    } catch (e) {
      loggerService.e('Error getting weather for search query: $location', e);
      weatherData = WeatherData.mock();

      if (context.mounted) {
        _showConnectionError(
          context,
          'Error getting weather data. Please try again later.',
          () => onSearchSubmitted(location, context)
        );
      }
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