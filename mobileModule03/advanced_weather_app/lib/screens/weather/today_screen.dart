import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/forecast/forecast.dart';
import '../../../core/theme/app_theme.dart';
import '../../models/location/location.dart';
import 'package:intl/intl.dart';

/// Screen to display today's hourly forecast
class TodayScreen extends StatelessWidget {
  final List<HourlyForecast>? hourlyForecasts;
  final Location? location;

  const TodayScreen({
    super.key,
    required this.hourlyForecasts,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location header
        _buildLocationHeader(context),

        // Temperature chart
        if (hourlyForecasts != null && hourlyForecasts!.isNotEmpty)
          _buildTemperatureChart(context),

        // Hourly forecast list
        Expanded(
          child: _buildHourlyForecastList(context),
        ),
      ],
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    String locationDisplay = location?.displayName ?? 'Today\'s Forecast';
    final currentDate = DateTime.now();
    final dateFormatter = DateFormat('EEEE, MMMM d'); // 例: Monday, May 13

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          locationDisplay,
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 0.06, maxSize: 24),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          dateFormatter.format(currentDate),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (location != null)
                    Text(
                      location!.locationDescription,
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Today\'s Hourly Forecast',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 0.045, maxSize: 18),
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecastList(BuildContext context) {
    if (hourlyForecasts == null || hourlyForecasts!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hourly forecast data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: hourlyForecasts!.length,
      itemBuilder: (context, index) {
        final forecast = hourlyForecasts![index];
        return _buildHourlyForecastItem(context, forecast);
      },
    );
  }

  Widget _buildHourlyForecastItem(BuildContext context, HourlyForecast forecast) {
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final isCurrent = forecast.time.hour == now.hour;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: isCurrent
          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
          : Colors.white.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      elevation: isCurrent ? 3 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Row(
          children: [
            // Left Column: Time
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeFormat.format(forecast.time),
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                      fontWeight: FontWeight.bold,
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  if (isCurrent)
                    const Text(
                      'Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Middle Column: Weather Icon and Condition
            Expanded(
              child: Row(
                children: [
                  // Weather Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getWeatherIcon(forecast.condition),
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Weather Condition
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          forecast.condition,
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context, 0.035, maxSize: 15),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Wind Speed
                        Row(
                          children: [
                            Icon(
                              Icons.air,
                              size: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${forecast.windSpeed.toStringAsFixed(1)} km/h',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right Column: Temperature
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: isCurrent
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${forecast.temperature.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 0.04, maxSize: 16),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains('sun') || condition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('rain')) {
      return Icons.grain;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return Icons.flash_on;
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return Icons.cloud_queue;
    } else {
      return Icons.cloud;
    }
  }

  /// Builds the temperature chart for the day
  Widget _buildTemperatureChart(BuildContext context) {
    // データが十分にない場合はグラフを表示しない（最低8時間分のデータが必要）
    if (hourlyForecasts == null || hourlyForecasts!.length < 8) {
      return const SizedBox.shrink();
    }

    // グラフには24時間（または利用可能な時間）表示する
    final displayCount = hourlyForecasts!.length > 24 ? 24 : hourlyForecasts!.length;
    final forecasts = hourlyForecasts!.take(displayCount).toList();

    // 気温の最大値と最小値を計算してYの範囲を決定する
    double minTemp = forecasts.map((f) => f.temperature).reduce((a, b) => a < b ? a : b);
    double maxTemp = forecasts.map((f) => f.temperature).reduce((a, b) => a > b ? a : b);

    // マージンを追加
    minTemp = minTemp - 3;
    maxTemp = maxTemp + 3;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0, 16, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Temperature Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  horizontalInterval: 5,
                  verticalInterval: 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < forecasts.length && index % 4 == 0) {
                          final hour = forecasts[index].time.hour;
                          return Text(
                            '$hour:00',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}°',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                minX: 0,
                maxX: forecasts.length.toDouble() - 1,
                minY: minTemp,
                maxY: maxTemp,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(forecasts.length, (index) {
                      return FlSpot(index.toDouble(), forecasts[index].temperature);
                    }),
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.0,
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}