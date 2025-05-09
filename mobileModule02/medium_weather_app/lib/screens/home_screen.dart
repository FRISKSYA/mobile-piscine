import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../config/constants.dart';
import '../widgets/search_bar.dart';
import '../widgets/weather_tab_bar.dart';
import '../widgets/tab_content.dart';
import '../widgets/location_search_results.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../models/geocoding/location.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';

/// Main home screen with tabs
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();

  // Mock weather data (to be replaced with actual API data)
  late WeatherData _weatherData;

  // Current location text to display
  String _currentLocation = '';
  bool _isUsingGeolocation = false;
  String _coordinatesText = '';
  bool _isLoadingLocation = false;
  bool _locationPermissionDenied = false;

  // Search results
  List<Location> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Set default tab to "Currently" (index 0)
    _tabController.index = 0;

    // Initialize mock weather data
    _weatherData = WeatherData.mock();

    // Add listener to search controller
    _searchController.addListener(_onSearchInputChanged);

    // Check for location permission on startup
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool hasPermission = await _locationService.isLocationPermissionGranted();
      setState(() {
        _locationPermissionDenied = !hasPermission;
      });
    } catch (e) {
      print('Error checking location permission: $e');
    }
  }

  void _onSearchInputChanged() {
    // Show search results when the user is typing
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _showSearchResults = true;
      });

      // Use debounce to prevent calling the API too frequently
      if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        _searchLocation(_searchController.text);
      });
    } else {
      _clearSearchResults();
    }
  }

  // Clear search results
  void _clearSearchResults() {
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });
  }

  // Search for locations by name
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await GeocodingService.searchLocation(query: query);
      setState(() {
        _searchResults = response.results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching locations: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Handle location selection from search results
  void _onLocationSelected(Location location) {
    setState(() {
      _currentLocation = location.name;
      _isUsingGeolocation = false;
      _coordinatesText = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
      _searchResults = [];
      _showSearchResults = false;
    });

    // Clear the search field
    _searchController.clear();

    // Show a snackbar to indicate that we're fetching the weather
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Getting weather for ${location.name}...')),
    );

    // Here you would typically call the weather API with location.latitude and location.longitude
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onLocationPressed() async {
    // Show loading state
    setState(() {
      _isLoadingLocation = true;
      _isUsingGeolocation = true;
    });
    
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
          setState(() {
            _locationPermissionDenied = true;
            _isLoadingLocation = false;
            _coordinatesText = '';
            _currentLocation = 'Location permission denied';
          });
          
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
      setState(() {
        _coordinatesText = formattedPosition;
        _currentLocation = 'Current Location';
        _isLoadingLocation = false;
        _locationPermissionDenied = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _coordinatesText = '';
        _currentLocation = 'Error getting location';
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    }
  }

  void _onSearchSubmitted(String location) {
    if (location.isEmpty) return;
    
    setState(() {
      _currentLocation = location;
      _isUsingGeolocation = false;
    });
    
    // Show a snackbar to indicate that we're searching for the weather
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for weather in $location...')),
    );
    
    // Clear the search field
    _searchController.clear();
  }

  /// Creates a subtitle text for a tab based on the current location
  String _getTabSubtitle(String tabName) {
    return _currentLocation.isEmpty 
        ? 'This is the $tabName tab content'
        : _currentLocation;
  }

  /// Creates a tab content widget for the given tab name
  TabContent _buildTabContent(String tabName, IconData icon) {
    return TabContent(
      tabName: tabName,
      icon: icon,
      title: '$tabName Tab',
      subtitle: _getTabSubtitle(tabName),
      extraInfo: _isUsingGeolocation ? _coordinatesText : '',
      isLoading: _isLoadingLocation,
    );
  }

  /// Builds all tab content widgets
  List<Widget> _buildTabContents() {
    return [
      // Currently tab content
      _buildTabContent(
        AppConstants.currentlyTabName, 
        Icons.access_time
      ),
      // Today tab content
      _buildTabContent(
        AppConstants.todayTabName, 
        Icons.today
      ),
      // Weekly tab content
      _buildTabContent(
        AppConstants.weeklyTabName, 
        Icons.calendar_view_week
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WeatherSearchBar(
          controller: _searchController,
          onLocationPressed: _onLocationPressed,
          onSubmitted: _onSearchSubmitted,
          onChanged: (value) => setState(() {}), // Update UI when text changes
          isSearching: _isSearching,
          onClearSearch: _clearSearchResults,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: _buildTabContents(),
            ),
          ),
          if (_showSearchResults && (_searchResults.isNotEmpty || _isSearching))
            Positioned(
              top: 0,
              left: 8,
              right: 8,
              child: SafeArea(
                child: LocationSearchResults(
                  locations: _searchResults,
                  onLocationSelected: _onLocationSelected,
                  isLoading: _isSearching,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: WeatherTabBar(controller: _tabController),
    );
  }
}