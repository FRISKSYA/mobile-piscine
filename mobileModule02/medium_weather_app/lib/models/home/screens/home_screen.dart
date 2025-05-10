import 'package:flutter/material.dart';
import '../../home/home_controller.dart';
import '../../weather/widgets/tab_content_builder.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_tab_bar.dart';
import '../../location/widgets/location_search_results.dart';

/// Main home screen with tabs
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // Controller to manage state and business logic
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _controller.init(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppSearchBar(
          controller: _controller.searchController,
          onLocationPressed: () => _onLocationPressed(context),
          onSubmitted: (location) async {
            await _controller.onSearchSubmitted(location, context);
            setState(() {});
          },
          onChanged: (value) => setState(() {}), // Update UI when text changes
          isSearching: _controller.searchManager.isSearching,
          onClearSearch: _controller.searchManager.clearSearchResults,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: TabBarView(
              controller: _controller.tabController,
              children: TabContentBuilder.buildTabContents(
                currentLocation: _controller.locationManager.currentLocation,
                isUsingGeolocation: _controller.locationManager.isUsingGeolocation,
                coordinatesText: _controller.locationManager.coordinatesText,
                isLoadingLocation: _controller.locationManager.isLoadingLocation,
                selectedLocation: _controller.selectedLocation,
                weatherData: _controller.weatherData,
                isLoadingWeather: _controller.isLoadingWeather,
              ),
            ),
          ),
          if (_controller.searchManager.showSearchResults &&
              (_controller.searchManager.searchResults.isNotEmpty || _controller.searchManager.isSearching))
            Positioned(
              top: 0,
              left: 8,
              right: 8,
              child: SafeArea(
                child: LocationSearchResults(
                  locations: _controller.searchManager.searchResults,
                  onLocationSelected: (location) => _onLocationSelected(location, context),
                  isLoading: _controller.searchManager.isSearching,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppTabBar(controller: _controller.tabController),
    );
  }

  // Handle location button press
  Future<void> _onLocationPressed(BuildContext context) async {
    await _controller.getCurrentLocation(context);
    // Update UI after location is fetched
    setState(() {});
  }

  // Handle location selection from search results
  Future<void> _onLocationSelected(location, BuildContext context) async {
    await _controller.onLocationSelected(location, context);
    // Update UI after location is selected
    setState(() {});
  }
}