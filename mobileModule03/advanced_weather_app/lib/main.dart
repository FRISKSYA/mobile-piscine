import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: const BackgroundContainer(child: HomePage()),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget that provides a consistent background image across the entire app
class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image that covers the entire screen
        Positioned.fill(
          child: Image.asset(
            'assets/images/weather_background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        // The actual content of the page
        child,
      ],
    );
  }
}