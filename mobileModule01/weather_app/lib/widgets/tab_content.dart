import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Reusable tab content widget
class TabContent extends StatelessWidget {
  final String tabName;
  final IconData icon;
  final String title;
  final String subtitle;

  const TabContent({
    super.key,
    required this.tabName,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  /// Builds the icon widget with responsive sizing
  Widget _buildIcon(BuildContext context) {
    return Icon(
      icon,
      size: AppTheme.getResponsiveFontSize(context, 0.15, maxSize: 100),
      color: Theme.of(context).colorScheme.primary.withAlpha(179), // 0.7 * 255 = 179
    );
  }

  /// Builds the title widget with appropriate styling
  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppTheme.getResponsiveFontSize(context, 0.06, maxSize: 32),
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Checks if the subtitle represents a custom location
  bool _isLocationSubtitle() {
    return subtitle.isNotEmpty && subtitle != 'This is the $tabName tab content';
  }

  /// Builds the location information with label and value
  Widget _buildLocationInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          'Location:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 0.05, maxSize: 24),
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds the default subtitle
  Widget _buildDefaultSubtitle(BuildContext context) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 20),
      ),
    );
  }

  /// Builds the appropriate subtitle based on content
  Widget _buildSubtitle(BuildContext context) {
    return _isLocationSubtitle() 
        ? _buildLocationInfo(context)
        : _buildDefaultSubtitle(context);
  }

  /// Calculates the minimum height for content to fill the screen
  double _calculateMinHeight(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return screenSize.height - 
        kToolbarHeight - 
        kBottomNavigationBarHeight - 
        MediaQuery.of(context).padding.top - 
        MediaQuery.of(context).padding.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: AppTheme.getResponsivePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: _calculateMinHeight(context)
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(context),
                const SizedBox(height: 16),
                _buildTitle(context),
                const SizedBox(height: 8),
                _buildSubtitle(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}