import 'package:flutter/material.dart';
import '../features/weather/controllers/home_view_model.dart';
import '../features/weather/widgets/tab_content_builder.dart';
import '../widgets/search_bar.dart';
import '../widgets/weather_tab_bar.dart';
import '../widgets/location_search_results.dart';

/// Main home screen with tabs
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // View model to manage state and business logic
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.init(this);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WeatherSearchBar(
          controller: _viewModel.searchController,
          onLocationPressed: () => _onLocationPressed(context),
          onSubmitted: (location) => _viewModel.onSearchSubmitted(location, context),
          onChanged: (value) => setState(() {}), // Update UI when text changes
          isSearching: _viewModel.searchManager.isSearching,
          onClearSearch: _viewModel.searchManager.clearSearchResults,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: TabBarView(
              controller: _viewModel.tabController,
              children: TabContentBuilder.buildTabContents(
                currentLocation: _viewModel.locationManager.currentLocation,
                isUsingGeolocation: _viewModel.locationManager.isUsingGeolocation,
                coordinatesText: _viewModel.locationManager.coordinatesText,
                isLoadingLocation: _viewModel.locationManager.isLoadingLocation,
              ),
            ),
          ),
          if (_viewModel.searchManager.showSearchResults && 
              (_viewModel.searchManager.searchResults.isNotEmpty || _viewModel.searchManager.isSearching))
            Positioned(
              top: 0,
              left: 8,
              right: 8,
              child: SafeArea(
                child: LocationSearchResults(
                  locations: _viewModel.searchManager.searchResults,
                  onLocationSelected: (location) => _onLocationSelected(location, context),
                  isLoading: _viewModel.searchManager.isSearching,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: WeatherTabBar(controller: _viewModel.tabController),
    );
  }

  // Handle location button press
  Future<void> _onLocationPressed(BuildContext context) async {
    await _viewModel.getCurrentLocation(context);
    // Update UI after location is fetched
    setState(() {});
  }

  // Handle location selection from search results
  void _onLocationSelected(location, BuildContext context) {
    _viewModel.onLocationSelected(location, context);
    // Update UI after location is selected
    setState(() {});
  }
}