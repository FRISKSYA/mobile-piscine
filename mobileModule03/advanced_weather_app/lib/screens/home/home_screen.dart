import 'package:flutter/material.dart';
import 'home_controller.dart';
import '../weather/tab_content_builder.dart';
import '../../core/widgets/app_search_bar.dart';
import '../../core/widgets/app_tab_bar.dart';
import '../../core/widgets/error_banner.dart';
import '../search/search_results_container.dart';

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
    // Check connection state on every build to ensure error message persists
    _controller.checkConnectionState();

    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold transparent to show background
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.8), // Semi-transparent app bar
        elevation: 0,
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
              child: ErrorBanner(
                errorMessage: _controller.errorMessage,
                isLocationError: _controller.isLocationNotFound,
                isConnectionError: _controller.isConnectionError,
                onRetry: _controller.isConnectionError
                    ? () {
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
                      }
                    : null,
                onClose: () {
                  _controller.clearError();
                  setState(() {});
                },
              ),
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
            SearchResultsContainer(
              locations: _controller.searchManager.searchResults,
              onLocationSelected: (location) => _onLocationSelected(location, context),
              isSearching: _controller.searchManager.isSearching,
              isConnectionError: _controller.isConnectionError && !_controller.hasError,
              errorMessage: _controller.errorMessage,
              hasErrorAbove: _controller.hasError,
              onRetry: () {
                if (_controller.locationManager.isUsingGeolocation) {
                  _onLocationPressed(context);
                } else if (_controller.selectedLocation != null) {
                  _onLocationSelected(_controller.selectedLocation!, context);
                } else {
                  _controller.onSearchSubmitted(_controller.locationManager.currentLocation, context);
                  setState(() {});
                }
              },
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.8), // Semi-transparent background
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: AppTabBar(controller: _controller.tabController),
      ),
    );
  }

  // Handle location button press
  Future<void> _onLocationPressed(BuildContext context) async {
    await _controller.getCurrentLocation(context);
    // Check connection state after attempting to fetch weather
    _controller.checkConnectionState();
    // Update UI after location is fetched
    setState(() {});
  }

  // Handle location selection from search results
  Future<void> _onLocationSelected(location, BuildContext context) async {
    await _controller.onLocationSelected(location, context);
    // Check connection state after attempting to fetch weather
    _controller.checkConnectionState();
    // Update UI after location is selected
    setState(() {});
  }

}