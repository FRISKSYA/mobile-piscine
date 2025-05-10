import 'dart:async';
import 'package:flutter/material.dart';
import '../common/location.dart';
import '../location/geocoding_service.dart';
import '../../core/utils/logger_service.dart';

class SearchManager {
  // Search state
  List<Location> searchResults = [];
  bool isSearching = false;
  Timer? searchDebounce;
  bool showSearchResults = false;

  // Search for locations by name
  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      clearSearchResults();
      return;
    }

    isSearching = true;

    try {
      final response = await GeocodingService.searchLocation(query: query);
      searchResults = response.results;
      isSearching = false;
    } catch (e) {
      loggerService.e('Error searching locations: $e');
      isSearching = false;
    }
  }

  // Clear search results
  void clearSearchResults() {
    searchResults = [];
    showSearchResults = false;
  }

  // Handle search input changes with debounce
  void onSearchInputChanged(String text, Function(String) searchCallback) {
    // Show search results when the user is typing
    if (text.isNotEmpty) {
      showSearchResults = true;
      loggerService.d('Search input changed: $text');

      // Use debounce to prevent calling the API too frequently
      if (searchDebounce?.isActive ?? false) searchDebounce!.cancel();
      searchDebounce = Timer(const Duration(milliseconds: 500), () {
        loggerService.i('Searching for: $text');
        searchCallback(text);
      });
    } else {
      clearSearchResults();
    }
  }

  // Handle location selection from search results
  void onLocationSelected(Location location, BuildContext context, TextEditingController searchController) {
    // Set location data
    searchResults = [];
    showSearchResults = false;

    // Clear the search field
    searchController.clear();

    // Show a snackbar to indicate that we're fetching the weather
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Getting weather for ${location.name}...')),
      );
    }
  }

  // Handle search submission
  void onSearchSubmitted(String location, BuildContext context, TextEditingController searchController) {
    if (location.isEmpty) return;

    // Show a snackbar to indicate that we're searching for the weather
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Searching for weather in $location...')),
      );
    }

    // Clear the search field
    searchController.clear();
  }

  // Clean up resources
  void dispose() {
    searchDebounce?.cancel();
  }
}