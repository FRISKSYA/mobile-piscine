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
    // This will be implemented to get current location
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Getting current location...')),
    );
  }

  void _onSearchSubmitted(String location) {
    if (location.isEmpty) return;
    
    // This will be implemented to search for weather at the specified location
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for weather in $location...')),
    );
    
    // Clear the search field
    _searchController.clear();
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
          children: [
            // Currently tab content
            TabContent(
              tabName: AppConstants.currentlyTabName,
              icon: Icons.access_time,
              title: '${AppConstants.currentlyTabName} Tab',
              subtitle: 'This is the ${AppConstants.currentlyTabName} tab content',
            ),
            // Today tab content
            TabContent(
              tabName: AppConstants.todayTabName,
              icon: Icons.today,
              title: '${AppConstants.todayTabName} Tab',
              subtitle: 'This is the ${AppConstants.todayTabName} tab content',
            ),
            // Weekly tab content
            TabContent(
              tabName: AppConstants.weeklyTabName,
              icon: Icons.calendar_view_week,
              title: '${AppConstants.weeklyTabName} Tab',
              subtitle: 'This is the ${AppConstants.weeklyTabName} tab content',
            ),
          ],
        ),
      ),
      bottomNavigationBar: WeatherTabBar(controller: _tabController),
    );
  }
}