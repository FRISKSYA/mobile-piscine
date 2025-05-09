import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../widgets/tab_content.dart';

class TabContentBuilder {
  /// Creates a subtitle text for a tab based on the current location
  static String getTabSubtitle(String tabName, String currentLocation) {
    return currentLocation.isEmpty 
        ? 'This is the $tabName tab content'
        : currentLocation;
  }

  /// Creates a tab content widget for the given tab name
  static TabContent buildTabContent({
    required String tabName, 
    required IconData icon,
    required String currentLocation,
    required bool isUsingGeolocation,
    required String coordinatesText,
    required bool isLoadingLocation,
  }) {
    return TabContent(
      tabName: tabName,
      icon: icon,
      title: '$tabName Tab',
      subtitle: getTabSubtitle(tabName, currentLocation),
      extraInfo: isUsingGeolocation ? coordinatesText : '',
      isLoading: isLoadingLocation,
    );
  }

  /// Builds all tab content widgets
  static List<Widget> buildTabContents({
    required String currentLocation,
    required bool isUsingGeolocation,
    required String coordinatesText,
    required bool isLoadingLocation,
  }) {
    return [
      // Currently tab content
      buildTabContent(
        tabName: AppConstants.currentlyTabName, 
        icon: Icons.access_time,
        currentLocation: currentLocation,
        isUsingGeolocation: isUsingGeolocation,
        coordinatesText: coordinatesText,
        isLoadingLocation: isLoadingLocation,
      ),
      // Today tab content
      buildTabContent(
        tabName: AppConstants.todayTabName, 
        icon: Icons.today,
        currentLocation: currentLocation,
        isUsingGeolocation: isUsingGeolocation,
        coordinatesText: coordinatesText,
        isLoadingLocation: isLoadingLocation,
      ),
      // Weekly tab content
      buildTabContent(
        tabName: AppConstants.weeklyTabName, 
        icon: Icons.calendar_view_week,
        currentLocation: currentLocation,
        isUsingGeolocation: isUsingGeolocation,
        coordinatesText: coordinatesText,
        isLoadingLocation: isLoadingLocation,
      ),
    ];
  }
}