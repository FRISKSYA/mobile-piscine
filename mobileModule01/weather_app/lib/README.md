# Weather App プロジェクト構造

このドキュメントでは、Weather App プロジェクトの構造とコードについて説明します。

## ディレクトリ構造

```
lib/
├── config/             # アプリ設定・定数・テーマ
├── models/             # データモデル
├── screens/            # 画面
├── services/           # API・バックエンドサービス
├── utils/              # ユーティリティ関数 (将来の拡張用)
├── widgets/            # 再利用可能なウィジェット
└── main.dart           # アプリケーションのエントリーポイント
```

## 主要ファイルの説明

### main.dart

メインアプリケーションのエントリーポイント。アプリケーション全体のテーマと初期画面を設定します。

```dart
import 'package:flutter/material.dart';
import 'config/constants.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';

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
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### config/

#### constants.dart

アプリ全体で使用する定数を定義します。

```dart
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App information
  static const String appName = 'Weather App';
  static const String appVersion = '1.0.0';

  // Tab names
  static const String currentlyTabName = 'Currently';
  static const String todayTabName = 'Today';
  static const String weeklyTabName = 'Weekly';

  // UI constants
  static const double smallScreenWidth = 600;
  static const double maxIconSize = 100;
  static const double maxHeadingFontSize = 32;
  static const double maxBodyFontSize = 20;

  // API constants (for future use)
  static const String apiBaseUrl = 'placeholder-for-weather-api-url';
  static const int apiTimeoutSeconds = 30;
}
```

#### theme.dart

アプリケーションのテーマ設定を定義します。色、フォント、スタイルなどのUIの設定が含まれています。

```dart
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // App colors
  static const Color primaryColor = Color(0xFF1976D2);
  // その他のテーマ設定...

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    // その他のテーマ設定...
  );

  // Helper methods for responsive design
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return EdgeInsets.all(width * 0.05);
  }

  static double getResponsiveFontSize(BuildContext context, double percent, {double? maxSize}) {
    final double width = MediaQuery.of(context).size.width;
    final double size = width * percent;
    return maxSize != null && size > maxSize ? maxSize : size;
  }
}
```

### models/

#### weather.dart

現在の天気情報を表すモデルクラスを定義します。

```dart
class Weather {
  final double temperature;
  final String condition;
  final String iconCode;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final DateTime time;
  final String location;

  Weather({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.time,
    required this.location,
  });

  // Factory constructor to create Weather from API JSON
  factory Weather.fromJson(Map<String, dynamic> json) { /* ... */ }

  // Create a mock weather object for testing
  factory Weather.mock() { /* ... */ }
}
```

#### forecast.dart

天気予報のデータモデルを定義します。

```dart
// 日別予報のモデル
class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  DailyForecast({ /* ... */ });

  factory DailyForecast.fromJson(Map<String, dynamic> json) { /* ... */ }
  factory DailyForecast.mock(int daysFromNow) { /* ... */ }
}

// 時間別予報のモデル
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;
  final String iconCode;

  HourlyForecast({ /* ... */ });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) { /* ... */ }
  factory HourlyForecast.mock(int hoursFromNow) { /* ... */ }
}

// すべての天気データを含むラッパークラス
class WeatherData {
  final Weather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherData({ /* ... */ });

  factory WeatherData.mock() { /* ... */ }
}
```

### screens/

#### home_screen.dart

アプリケーションのメイン画面であり、タブバーとタブコンテンツを管理します。

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // Mock weather data (to be replaced with actual API data)
  late WeatherData _weatherData;

  @override
  void initState() { /* ... */ }

  @override
  void dispose() { /* ... */ }

  void _onLocationPressed() { /* ... */ }

  void _onSearchSubmitted(String location) { /* ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WeatherSearchBar(
          controller: _searchController,
          onLocationPressed: _onLocationPressed,
          onSubmitted: _onSearchSubmitted,
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // タブコンテンツ...
          ],
        ),
      ),
      bottomNavigationBar: WeatherTabBar(controller: _tabController),
    );
  }
}
```

#### currently_screen.dart

現在の天気を表示する画面です。

```dart
class CurrentlyScreen extends StatelessWidget {
  final Weather weather;

  const CurrentlyScreen({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    // 現在の画面コンテンツ
  }
}
```

#### today_screen.dart

本日の時間別予報を表示する画面です。

```dart
class TodayScreen extends StatelessWidget {
  final List<HourlyForecast> hourlyForecasts;

  const TodayScreen({
    super.key,
    required this.hourlyForecasts,
  });

  @override
  Widget build(BuildContext context) {
    // 本日の予報画面コンテンツ
  }
}
```

#### weekly_screen.dart

週間予報を表示する画面です。

```dart
class WeeklyScreen extends StatelessWidget {
  final List<DailyForecast> dailyForecasts;

  const WeeklyScreen({
    super.key,
    required this.dailyForecasts,
  });

  @override
  Widget build(BuildContext context) {
    // 週間予報画面コンテンツ
  }
}
```

### services/

#### weather_service.dart

天気APIとの通信を行うサービスクラスです。将来的な実装のためのプレースホルダーです。

```dart
class WeatherService {
  // This is a placeholder for future API integration

  /// Get current weather for a location
  Future<Weather> getCurrentWeather(String location) async { /* ... */ }

  /// Get hourly forecast for today
  Future<List<HourlyForecast>> getHourlyForecast(String location) async { /* ... */ }

  /// Get daily forecast for the week
  Future<List<DailyForecast>> getDailyForecast(String location) async { /* ... */ }

  /// Get complete weather data for a location
  Future<WeatherData> getWeatherData(String location) async { /* ... */ }
}
```

### widgets/

#### search_bar.dart

検索バーと位置情報ボタンを含むカスタムウィジェットです。

```dart
class WeatherSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onLocationPressed;
  final ValueChanged<String>? onSubmitted;

  const WeatherSearchBar({ /* ... */ });

  @override
  Widget build(BuildContext context) {
    // 検索バーのUI
  }
}
```

#### tab_content.dart

タブコンテンツの共通レイアウトを定義する再利用可能なウィジェットです。

```dart
class TabContent extends StatelessWidget {
  final String tabName;
  final IconData icon;
  final String title;
  final String subtitle;

  const TabContent({ /* ... */ });

  @override
  Widget build(BuildContext context) {
    // 共通タブコンテンツレイアウト
  }
}
```

#### weather_tab_bar.dart

アプリのボトムタブバーを定義するウィジェットです。

```dart
class WeatherTabBar extends StatelessWidget {
  final TabController controller;

  const WeatherTabBar({ /* ... */ });

  @override
  Widget build(BuildContext context) {
    // タブバーのUI
  }
}
```

## アーキテクチャの概要

このアプリケーションは以下のアーキテクチャパターンに従っています：

1. **分離されたレイヤー**：UI、ビジネスロジック、データアクセスが明確に分離されています。
2. **再利用可能なコンポーネント**：ウィジェットは再利用可能で、単一責任の原則に従っています。
3. **将来の拡張性**：APIとの統合や新機能の追加が容易な構造になっています。
4. **レスポンシブデザイン**：様々な画面サイズに対応するためのヘルパーメソッドが組み込まれています。

## 今後の拡張

このプロジェクト構造は、以下のような将来の拡張を見据えています：

1. **実際の天気API統合**：`services`ディレクトリにAPIクライアントを追加。
2. **状態管理**：より複雑なアプリケーション状態を管理するためのProviderパターンの追加。
3. **テーマの拡張**：ダークモードのサポートや、カスタムテーマオプションの追加。
4. **キャッシュとオフラインサポート**：ローカルデータ保存とオフラインモードのサポート。

## まとめ

Weather Appは、明確な責任分離と将来の拡張性を持つ、整理された構造を持つFlutterアプリケーションです。この構造により、新機能の追加やコード保守が容易になります。