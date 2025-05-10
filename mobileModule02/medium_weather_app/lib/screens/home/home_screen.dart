import 'package:flutter/material.dart';
import 'home_controller.dart';
import '../weather/tab_content_builder.dart';
import '../../core/widgets/app_search_bar.dart';
import '../../core/widgets/app_tab_bar.dart';
import '../location/location_search_results.dart';

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
          // Error message banner displayed at the top when there's an error
          if (_controller.hasError)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildErrorBanner(context),
            ),

          SafeArea(
            child: Column(
              children: [
                // Add space for the error banner if it's displayed
                if (_controller.hasError)
                  const SizedBox(height: 48), // Height of the error banner

                Expanded(
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
              ],
            ),
          ),

          if (_controller.searchManager.showSearchResults &&
              (_controller.searchManager.searchResults.isNotEmpty || _controller.searchManager.isSearching))
            Positioned(
              top: _controller.hasError ? 48 : 0, // Adjust position based on error banner
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

  // Build an error banner for persistent error messages
  Widget _buildErrorBanner(BuildContext context) {
    return Material(
      elevation: 4,
      child: Container(
        color: _controller.isLocationNotFound ? Colors.orange : Colors.red.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(
                _controller.isLocationNotFound ? Icons.location_off : Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _controller.errorMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              if (_controller.isConnectionError)
                TextButton(
                  onPressed: () {
                    // Retry the last action based on the current location
                    if (_controller.locationManager.isUsingGeolocation) {
                      _onLocationPressed(context);
                    } else if (_controller.selectedLocation != null) {
                      _onLocationSelected(_controller.selectedLocation!, context);
                    } else {
                      // Retry with the current location name
                      _controller.onSearchSubmitted(_controller.locationManager.currentLocation, context);
                      setState(() {});
                    }
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () {
                    _controller.clearError();
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}