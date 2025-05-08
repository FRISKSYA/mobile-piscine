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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return SingleChildScrollView(
      child: Padding(
        padding: AppTheme.getResponsivePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenSize.height - 
              kToolbarHeight - 
              kBottomNavigationBarHeight - 
              MediaQuery.of(context).padding.top - 
              MediaQuery.of(context).padding.bottom
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: AppTheme.getResponsiveFontSize(context, 0.15, maxSize: 100),
                  color: Theme.of(context).colorScheme.primary.withAlpha(179), // 0.7 * 255 = 179
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 0.06, maxSize: 32),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}