import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/search_bar.dart';
import '../widgets/weather_tab_bar.dart';
import '../widgets/tab_content.dart';
import '../models/weather.dart';
import '../models/forecast.dart';

/// Main home screen with tabs
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // Mock weather data (to be replaced with actual API data)
  late WeatherData _weatherData;
  
  // Current location text to display
  String _currentLocation = '';
  bool _isUsingGeolocation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Set default tab to "Currently" (index 0)
    _tabController.index = 0;
    
    // Initialize mock weather data
    _weatherData = WeatherData.mock();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onLocationPressed() {
    // Set the current location to "Geolocation"
    setState(() {
      _currentLocation = 'Geolocation';
      _isUsingGeolocation = true;
    });
    
    // Show a snackbar to indicate that we're getting the current location
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Getting current location...')),
    );
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