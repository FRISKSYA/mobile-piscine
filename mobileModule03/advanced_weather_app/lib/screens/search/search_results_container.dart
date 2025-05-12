import 'package:flutter/material.dart';
import '../../core/widgets/error_banner.dart';
import '../location/location_search_results.dart';
import '../../models/location/location.dart';

/// A container widget for displaying search results
class SearchResultsContainer extends StatelessWidget {
  /// List of location search results to display
  final List<Location> locations;
  
  /// Callback when a location is selected from the results
  final Function(Location) onLocationSelected;
  
  /// Whether the search is currently in progress
  final bool isSearching;
  
  /// Whether to show a connection error
  final bool isConnectionError;
  
  /// Error message to display (if isConnectionError is true)
  final String errorMessage;
  
  /// Callback when retry button is pressed on error banner
  final VoidCallback? onRetry;
  
  /// Whether an error banner is already shown above (to adjust positioning)
  final bool hasErrorAbove;

  const SearchResultsContainer({
    super.key,
    required this.locations,
    required this.onLocationSelected,
    required this.isSearching,
    this.isConnectionError = false,
    this.errorMessage = '',
    this.onRetry,
    this.hasErrorAbove = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: hasErrorAbove ? 48 : 0,
      left: 8,
      right: 8,
      child: SafeArea(
        child: Column(
          children: [
            // Show connection error above search results if needed
            if (isConnectionError)
              ErrorBanner(
                errorMessage: errorMessage,
                isConnectionError: true,
                onRetry: onRetry,
              ),
            LocationSearchResults(
              locations: locations,
              onLocationSelected: onLocationSelected,
              isLoading: isSearching,
            ),
          ],
        ),
      ),
    );
  }
}