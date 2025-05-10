import 'package:flutter/material.dart';
import '../../../models/weather.dart';
import '../../../models/forecast.dart';
import '../../../models/geocoding/location.dart';
import '../../../config/constants.dart';
import '../../../services/weather_service.dart';
import '../../../utils/logger_service.dart';
import '../../location/managers/location_manager.dart';
import '../../search/managers/search_manager.dart';

class HomeViewModel {
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
      weatherData = await weatherService.getWeatherData('Tokyo');
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
          weatherData = await weatherService.getCurrentLocationWeather(latitude, longitude);
          loggerService.i('Loaded weather data for current location');
        }
      } catch (e) {
        loggerService.e('Error getting weather for current location', e);
        weatherData = WeatherData.mock();
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

    // Store the selected location object to display in weather screens
    selectedLocation = location;

    // Get weather data for the selected location
    try {
      // Use the location coordinates directly since we already have them
      weatherData = await weatherService.getWeatherByCoordinates(
        location.latitude,
        location.longitude,
        location.displayName
      );
      loggerService.i('Loaded weather data for ${location.name}');
    } catch (e) {
      loggerService.e('Error getting weather for location ${location.name}', e);
      weatherData = WeatherData.mock();
    }

    searchManager.onLocationSelected(location, context, searchController);
    isLoadingWeather = false;
  }

  // Handle search submission
  Future<void> onSearchSubmitted(String location, BuildContext context) async {
    if (location.isEmpty) return;

    isLoadingWeather = true;
    locationManager.currentLocation = location;
    locationManager.isUsingGeolocation = false;

    // Get weather data for the submitted location
    try {
      weatherData = await weatherService.getWeatherData(location);
      loggerService.i('Loaded weather data for search query: $location');

      // Reset selected location since this is a direct search
      selectedLocation = null;
    } catch (e) {
      loggerService.e('Error getting weather for search query: $location', e);
      weatherData = WeatherData.mock();
    }

    searchManager.onSearchSubmitted(location, context, searchController);
    isLoadingWeather = false;
  }

  // Clean up resources
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    searchManager.dispose();
  }
}