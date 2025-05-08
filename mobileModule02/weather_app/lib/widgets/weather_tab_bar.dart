import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/theme.dart';

/// Bottom tab bar for the weather app
class WeatherTabBar extends StatelessWidget {
  final TabController controller;

  const WeatherTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = AppTheme.isSmallScreen(context);

    return BottomAppBar(
      elevation: 8,
      child: TabBar(
        controller: controller,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          fontSize: isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.access_time),
            text: AppConstants.currentlyTabName,
          ),
          Tab(
            icon: Icon(Icons.today),
            text: AppConstants.todayTabName,
          ),
          Tab(
            icon: Icon(Icons.calendar_view_week),
            text: AppConstants.weeklyTabName,
          ),
        ],
      ),
    );
  }
}