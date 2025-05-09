import 'package:flutter/material.dart';
import '../../../models/weather.dart';
import '../../../models/geocoding/location.dart';
import '../../../config/constants.dart';
import '../../location/managers/location_manager.dart';
import '../../search/managers/search_manager.dart';

class HomeViewModel {
  // Managers
  final LocationManager locationManager = LocationManager();
  final SearchManager searchManager = SearchManager();

  // Controllers
  late TabController tabController;
  final TextEditingController searchController = TextEditingController();

  // Weather data
  late Weather weather;
  
  // Initialize the view model
  void init(TickerProvider vsync) {
    tabController = TabController(length: 3, vsync: vsync);
    // Set default tab to "Currently" (index 0)
    tabController.index = 0;

    // Initialize mock weather data
    weather = Weather.mock();
    
    // Add listener to search controller
    searchController.addListener(_onSearchChanged);
    
    // Check for location permission on startup
    locationManager.checkLocationPermission();
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
    await locationManager.getCurrentLocation(context);
  }
  
  // Handle location selection from search results
  void onLocationSelected(Location location, BuildContext context) {
    locationManager.currentLocation = location.name;
    locationManager.isUsingGeolocation = false;
    locationManager.coordinatesText = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
    
    searchManager.onLocationSelected(location, context, searchController);
  }
  
  // Handle search submission
  void onSearchSubmitted(String location, BuildContext context) {
    if (location.isEmpty) return;
    
    locationManager.currentLocation = location;
    locationManager.isUsingGeolocation = false;
    
    searchManager.onSearchSubmitted(location, context, searchController);
  }
  
  // Clean up resources
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    searchManager.dispose();
  }
}