import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/forecast/forecast.dart';

/// A chart widget to display weekly temperature forecast
class WeeklyForecastChart extends StatelessWidget {
  final List<DailyForecast> dailyForecasts;
  final Color minColor;
  final Color maxColor;

  const WeeklyForecastChart({
    super.key,
    required this.dailyForecasts,
    required this.minColor,
    required this.maxColor,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withAlpha(77), // 0.3 * 255 ≈ 77
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withAlpha(51), // 0.2 * 255 ≈ 51
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: bottomTitleWidgets,
              reservedSize: 42,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 42,
              interval: 5,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withAlpha(102), width: 1), // 0.4 * 255 ≈ 102
            left: BorderSide(color: Colors.grey.withAlpha(102), width: 1), // 0.4 * 255 ≈ 102
            right: const BorderSide(color: Colors.transparent),
            top: const BorderSide(color: Colors.transparent),
          ),
        ),
        minX: 0,
        maxX: dailyForecasts.length.toDouble() - 1,
        minY: _calculateMinY(),
        maxY: _calculateMaxY(),
        lineBarsData: [
          // Max temperature line
          LineChartBarData(
            spots: _createMaxTempSpots(),
            isCurved: true,
            color: maxColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: false,
              color: maxColor.withAlpha(51), // 0.2 * 255 ≈ 51
            ),
          ),
          // Min temperature line
          LineChartBarData(
            spots: _createMinTempSpots(),
            isCurved: true,
            color: minColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: false,
              color: minColor.withAlpha(51), // 0.2 * 255 ≈ 51
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white.withAlpha(204), // 0.8 * 255 ≈ 204
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final temp = '${spot.y.toStringAsFixed(1)}°C';
                final isMax = spot.barIndex == 0; // 0 is max temp, 1 is min temp

                return LineTooltipItem(
                  temp,
                  TextStyle(
                    color: isMax ? maxColor : minColor,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _calculateMinY() {
    if (dailyForecasts.isEmpty) return 0;

    double min = dailyForecasts[0].minTemp;
    for (var forecast in dailyForecasts) {
      if (forecast.minTemp < min) {
        min = forecast.minTemp;
      }
    }
    // Round down to nearest multiple of 5 and subtract 5 for padding
    return (min / 5).floor() * 5 - 5;
  }

  double _calculateMaxY() {
    if (dailyForecasts.isEmpty) return 30;

    double max = dailyForecasts[0].maxTemp;
    for (var forecast in dailyForecasts) {
      if (forecast.maxTemp > max) {
        max = forecast.maxTemp;
      }
    }
    // Round up to nearest multiple of 5 and add 5 for padding
    return (max / 5).ceil() * 5 + 5;
  }

  List<FlSpot> _createMaxTempSpots() {
    return List.generate(
      dailyForecasts.length,
      (index) => FlSpot(index.toDouble(), dailyForecasts[index].maxTemp),
    );
  }

  List<FlSpot> _createMinTempSpots() {
    return List.generate(
      dailyForecasts.length,
      (index) => FlSpot(index.toDouble(), dailyForecasts[index].minTemp),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.grey.shade800,
    );

    final dayIndex = value.toInt();
    if (dayIndex < 0 || dayIndex >= dailyForecasts.length) {
      return const SizedBox.shrink();
    }

    String text;
    final date = dailyForecasts[dayIndex].date;

    if (dayIndex == 0) {
      text = 'Today';
    } else {
      // Format as day of week abbreviated (Mon, Tue, etc.)
      text = DateFormat('E').format(date);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.grey.shade800,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text('${value.toInt()}°', style: style),
    );
  }
}