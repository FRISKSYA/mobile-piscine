import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../config/constants.dart';
import '../widgets/search_bar.dart';
import '../widgets/weather_tab_bar.dart';
import '../widgets/tab_content.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../services/location_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Set default tab to "Currently" (index 0)
    _tabController.index = 0;
    
    // Initialize mock weather data
    _weatherData = WeatherData.mock();
    
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

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: _buildTabContents(),
        ),
      ),
      bottomNavigationBar: WeatherTabBar(controller: _tabController),
    );
  }
}