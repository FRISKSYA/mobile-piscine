import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../models/location/location.dart';

/// A card that displays location information
class LocationInfoCard extends StatelessWidget {
  /// The location to display information for
  final Location? location;
  
  /// Fallback location name if location is null
  final String fallbackLocationName;

  const LocationInfoCard({
    super.key,
    this.location,
    required this.fallbackLocationName,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which location name to display
    String locationDisplay = location?.displayName ?? fallbackLocationName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 28,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationDisplay,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 0.07, maxSize: 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (location != null)
                  Text(
                    location!.locationDescription,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 18),
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}