# Weather App プロジェクト構造

このドキュメントでは、Weather App プロジェクトの構造とコードについて説明します。

## 機能概要

このWeather Appは以下の機能を提供します：

1. **検索機能**: トップバーの検索フィールドに場所を入力することで、その場所の情報を表示できます。都市名を入力すると候補リストが表示され、選択できます。
2. **位置情報機能**: トップバーの位置情報ボタンをクリックすることで、現在地の情報を取得できます。
3. **タブ表示**: 「Currently（現在）」「Today（今日）」「Weekly（週間）」の3つのタブで異なる時間軸の天気情報を表示します。

## 新機能：都市名検索と候補表示

Open-MeteoのジオコーディングAPIを使用して、以下の機能を実装しました：

1. **都市名検索**: 都市名、国、地域などの入力に基づいて、一致する場所のリストを表示
2. **検索結果表示**: 各結果に都市名、地域（admin1）、国名を表示
3. **リアルタイム候補表示**: 入力中にリアルタイムで候補が更新される
4. **都市選択機能**: 候補リストから特定の都市を選択できる

## 新機能：天気情報の表示

Open-Meteoの天気予報APIを使用して、以下の情報を各タブに表示するように実装しました：

### Currentlyタブ（現在の天気）
- **位置情報**: 都市名、地域、国名
- **現在の天気**: 気温（摂氏）、天気の状態（曇り、晴れなど）
- **詳細情報**: 風速（km/h）、湿度（%）、体感温度（摂氏）

### Todayタブ（今日の予報）
- **位置情報**: 都市名、地域、国名
- **時間ごとの天気リスト**:
  - 時間帯（時：分）
  - 各時間の気温（摂氏）
  - 各時間の天気状態（アイコンと説明）
  - 各時間の風速（km/h）

### Weeklyタブ（週間予報）
- **位置情報**: 都市名、地域、国名
- **日ごとの天気リスト**:
  - 日付（曜日と日）
  - 最高気温と最低気温（摂氏）
  - 天気の説明（アイコンと説明）

## 新機能：Open-Meteo API統合とエラー処理の改善

Open-Meteoの無料APIを利用して、実際の天気データを取得・表示する機能と、改善されたエラー処理を実装しました：

### WeatherServiceの実装
- **APIエンドポイント**: `https://api.open-meteo.com/v1/forecast`
- **取得データ**:
  - 現在の天気: 気温、湿度、体感温度、降水量、天気コード、風速
  - 時間ごとの予報: 24時間分の同様のデータ
  - 日ごとの予報: 7日分の最高/最低気温、天気コード、降水量の合計
- **エラー処理**: 接続エラーや無効なデータに対して、null値を返してUIにエラー状態を伝達

### 天気コードの変換
- Open-MeteoのWMO天気コードを、人間が読みやすい説明（「晴れ」「曇り」など）に変換
- 天気コードに基づいて適切なアイコンを表示

### エラー処理と表示
- ネットワークエラーや無効な位置情報に対処するためのエラー処理を実装
- API呼び出しに失敗した場合、代わりにエラーメッセージを表示し、データは表示しない

### ロギング機能
- print文からloggerServigeへの移行により、より構造化されたログ出力
- 各種操作（API呼び出し、エラーなど）をログレベルに応じて記録

## ディレクトリ構造

```
lib/
├── main.dart                            # アプリのエントリーポイント
├── core/                                # 共通コンポーネント
│   ├── constants/                       # 定数定義
│   │   └── app_constants.dart           # アプリ名やAPI関連の定数など
│   ├── theme/                           # テーマ関連
│   │   └── app_theme.dart               # アプリのテーマ設定
│   ├── utils/                           # 共通ユーティリティ
│   │   └── logger_service.dart          # ロガーサービス
│   └── widgets/                         # 共通ウィジェット
│       ├── app_search_bar.dart          # 検索バー
│       └── app_tab_bar.dart             # タブバー
│
├── models/                              # データモデルとAPI接続
│   ├── forecast/                        # 予報関連
│   │   └── forecast.dart                # 予報データモデル
│   ├── location/                        # 位置情報関連
│   │   ├── location.dart                # 位置情報データモデル
│   │   ├── geocoding_service.dart       # ジオコーディングサービス
│   │   └── location_service.dart        # 位置情報サービス
│   └── weather/                         # 天気関連
│       ├── weather.dart                 # 天気データモデル
│       └── weather_service.dart         # 天気API通信
│
└── screens/                             # 画面コンポーネント
    ├── home/                            # ホーム画面
    │   ├── home_screen.dart             # ホーム画面
    │   └── home_controller.dart         # コントローラー
    ├── weather/                         # 天気画面
    │   ├── currently_screen.dart        # 現在の天気画面
    │   ├── today_screen.dart            # 今日の天気画面
    │   ├── weekly_screen.dart           # 週間予報画面
    │   ├── tab_content_builder.dart     # タブコンテンツビルダー
    │   └── tab_content.dart             # タブコンテンツ
    ├── location/                        # 位置情報画面
    │   ├── location_manager.dart        # 位置管理
    │   └── location_search_results.dart # 位置検索結果
    └── search/                          # 検索機能
        └── search_manager.dart          # 検索管理
```

## コード設計と実装パターン

### モジュール分割とヘルパーメソッド

コードを可読性と保守性を高めるために、以下のような設計パターンを採用しています：

1. **関数の分割**: 大きなクラスや関数を小さな関数に分割し、一つの関数が一つの責任を持つようにしています。
2. **ヘルパーメソッド**: UIコンポーネントの構築を担当する専用のメソッドを作成しています。
3. **状態管理の分離**: 状態の更新と表示ロジックを明確に分離しています。

### 検索機能と位置情報機能

`home_screen.dart`では、位置情報の状態管理を行い、タブコンテンツに情報を渡しています：

```dart
// 現在の位置情報を保持
String _currentLocation = '';
bool _isUsingGeolocation = false;
String _coordinatesText = ''; // 座標情報を保持
bool _isLoadingLocation = false; // 位置情報取得中の状態
bool _locationPermissionDenied = false; // 位置情報の許可状態

// 位置情報ボタンが押された時の処理
void _onLocationPressed() async {
  // ローディング状態を表示
  setState(() {
    _isLoadingLocation = true;
    _isUsingGeolocation = true;
  });
  
  // 位置情報を取得中であることを通知
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Getting current location...')),
  );
  
  try {
    // 位置情報の許可状態を確認
    bool hasPermission = await _locationService.isLocationPermissionGranted();
    
    if (!hasPermission) {
      // 許可が得られていない場合は許可をリクエスト
      hasPermission = await _locationService.requestLocationPermission();
      
      if (!hasPermission) {
        // 許可が拒否された場合の処理
        setState(() {
          _locationPermissionDenied = true;
          _isLoadingLocation = false;
          _coordinatesText = '';
          _currentLocation = 'Location permission denied';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied. Please enable it in app settings.'),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
    }
    
    // 現在の位置情報を取得
    Position position = await _locationService.getCurrentLocation();
    
    // 位置情報を表示用にフォーマット
    String formattedPosition = _locationService.formatPosition(position);
    
    // 状態を更新
    setState(() {
      _coordinatesText = formattedPosition;
      _currentLocation = 'Current Location';
      _isLoadingLocation = false;
      _locationPermissionDenied = false;
    });
  } catch (e) {
    // エラー処理
    setState(() {
      _isLoadingLocation = false;
      _coordinatesText = '';
      _currentLocation = 'Error getting location';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error getting location: ${e.toString()}')),
    );
  }
}

// 検索が実行された時の処理
void _onSearchSubmitted(String location) {
  if (location.isEmpty) return;
  
  setState(() {
    _currentLocation = location;
    _isUsingGeolocation = false;
  });
  
  // 省略...
}

// タブのサブタイトルを取得するヘルパーメソッド
String _getTabSubtitle(String tabName) {
  return _currentLocation.isEmpty 
      ? 'This is the $tabName tab content'
      : _currentLocation;
}
```

### タブコンテンツの作成

タブコンテンツの作成も、専用のヘルパーメソッドに分離されています：

```dart
/// タブコンテンツウィジェットを作成する
TabContent _buildTabContent(String tabName, IconData icon) {
  return TabContent(
    tabName: tabName,
    icon: icon,
    title: '$tabName Tab',
    subtitle: _getTabSubtitle(tabName),
    extraInfo: _isUsingGeolocation ? _coordinatesText : '', // 座標情報を表示
    isLoading: _isLoadingLocation, // 読み込み状態を反映
  );
}

/// すべてのタブコンテンツウィジェットを構築する
List<Widget> _buildTabContents() {
  return [
    // Currently tab content
    _buildTabContent(
      AppConstants.currentlyTabName, 
      Icons.access_time
    ),
    // 他のタブ...
  ];
}
```

### UIコンポーネントの分離

`TabContent`ウィジェットでは、UIの各パーツを別々のメソッドに分離しています：

```dart
/// アイコンウィジェットを構築する
Widget _buildIcon(BuildContext context) {
  return Icon(
    icon,
    size: AppTheme.getResponsiveFontSize(context, 0.15, maxSize: 100),
    color: Theme.of(context).colorScheme.primary.withAlpha(179),
  );
}

/// サブタイトルが位置情報を表すかチェックする
bool _isLocationSubtitle() {
  return subtitle.isNotEmpty && subtitle != 'This is the $tabName tab content';
}

/// 位置情報表示用のUIを構築する
Widget _buildLocationInfo(BuildContext context) {
  return Column(
    children: [
      Text('Location:', /* スタイル設定 */),
      const SizedBox(height: 4),
      Text(subtitle, /* スタイル設定 */),
    ],
  );
}

/// コンテンツに応じたサブタイトルを構築する
Widget _buildSubtitle(BuildContext context) {
  return _isLocationSubtitle() 
      ? _buildLocationInfo(context)
      : _buildDefaultSubtitle(context);
}
```

## 主要ファイルの説明

### main.dart

メインアプリケーションのエントリーポイント。アプリケーション全体のテーマと初期画面を設定します。

### core/constants/app_constants.dart

アプリ全体で使用する定数を定義します。タブ名や最大フォントサイズなどが含まれています。

### core/theme/app_theme.dart

アプリケーションのテーマ設定を定義します。色、フォント、スタイルなどのUIの設定と、レスポンシブデザインのためのユーティリティメソッドが含まれています。

### screens/home/home_screen.dart

アプリケーションのメイン画面であり、タブバーとタブコンテンツを管理します。検索機能と位置情報機能も実装しています。ユーザー入力の処理とタブコンテンツの作成を別々のメソッドに分離しています。位置情報の取得と表示を担当します。

### models/location/location_service.dart

位置情報サービスを提供するクラスです。デバイスのGPS機能を利用して現在位置の座標を取得したり、位置情報の権限を管理したりします。主な機能は以下の通りです：

1. 現在位置の取得: `getCurrentLocation()`メソッドを使用してデバイスの現在の位置情報を取得します。
2. 位置情報の許可状態の確認: `isLocationPermissionGranted()`メソッドで位置情報の権限が与えられているかを確認します。
3. 位置情報の許可のリクエスト: `requestLocationPermission()`メソッドで位置情報の権限をユーザーにリクエストします。
4. 座標のフォーマット: `formatPosition()`メソッドで位置情報を人間が読みやすい形式に変換します。

### screens/weather/tab_content.dart

タブコンテンツの共通レイアウトを定義する再利用可能なウィジェットです。UI要素の構築を複数のヘルパーメソッドに分離し、コードの可読性と保守性を高めています。位置情報の座標などの追加情報と読み込み状態を表示する機能が追加されました。

## 使い方

1. アプリを起動すると、3つのタブ（Currently、Today、Weekly）を持つ画面が表示されます。
2. 上部の検索バーに場所の名前を入力し、キーボードの実行ボタンをタップすると、その場所の情報が全タブに表示されます。
3. 右上の位置情報ボタンをタップすると、アプリは位置情報の許可をリクエストします。
   - 許可された場合は、現在位置の座標（緯度と経度）がタブに表示されます。
   - 許可が拒否された場合は、エラーメッセージが表示され、ユーザーは手動で場所を検索する必要があります。
4. 位置情報の取得中は、ローディングインジケーターが表示されます。
5. 下部のタブバーで各タブを切り替えることができます。

## 天気表示の実装

各タブでの天気情報の表示は、以下のコンポーネントを用いて実装しています：

### models/weather/screens/currently_screen.dart
現在の天気を表示するスクリーンで、以下のコンポーネントで構成されています：
```dart
Widget build(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 位置情報の表示
        _buildLocationInfo(context),
        const SizedBox(height: 24),

        // 現在の天気情報の表示
        _buildWeatherSection(context),
      ],
    ),
  );
}
```

### models/weather/screens/today_screen.dart
時間ごとの予報を表示するスクリーンで、ListView.builderを使用してリスト表示しています：
```dart
Widget _buildHourlyForecastList(BuildContext context) {
  return ListView.builder(
    padding: const EdgeInsets.all(8.0),
    itemCount: hourlyForecasts.length,
    itemBuilder: (context, index) {
      final forecast = hourlyForecasts[index];
      return _buildHourlyForecastItem(context, forecast);
    },
  );
}
```

### models/weather/screens/weekly_screen.dart
日ごとの予報を表示するスクリーンで、同様にリスト表示しています：
```dart
Widget _buildDailyForecastItem(BuildContext context, DailyForecast forecast, int index) {
  final dateFormat = DateFormat('E, MMM d');
  final isToday = index == 0;

  return Card(
    // 日付、天気状態、最高・最低気温の表示
    // ...
  );
}
```

## API統合の実装

アプリケーションは、Open-Meteo APIとの統合を通じて実際の天気データを取得し表示します。

### models/weather/weather_service.dart
天気APIとの通信を担当するサービスクラスと、データとエラー情報を持つWeatherResultクラスです：

```dart
/// エラー情報を含む天気データの結果クラス
class WeatherResult {
  final WeatherData data;
  final bool locationFound;
  final bool connectionError;
  final String errorMessage;

  WeatherResult({
    required this.data,
    this.locationFound = true,
    this.connectionError = false,
    this.errorMessage = '',
  });
}

class WeatherService {
  // Open-Meteo API URLs
  static const String _weatherApiUrl = 'https://api.open-meteo.com/v1/forecast';

  // Weather variables to request
  static const List<String> _weatherVariables = [
    'temperature_2m',
    'relative_humidity_2m',
    'apparent_temperature',
    'precipitation',
    'weather_code',
    'wind_speed_10m',
  ];

  /// 都市名から天気データを取得
  Future<WeatherResult> getWeatherData(String locationName) async {
    try {
      // 1. GeocodingServiceで座標を取得
      final geocodingResponse = await GeocodingService.searchLocation(query: locationName);

      // 位置情報が見つかったかチェック
      if (geocodingResponse.results.isNotEmpty) {
        // 位置情報を使って天気データを取得
        try {
          final weatherData = await _fetchWeatherByCoordinates(
            geocodingResponse.results[0].latitude,
            geocodingResponse.results[0].longitude,
            geocodingResponse.results[0].displayName
          );

          // 成功時は正常なデータを返す
          return WeatherResult(
            data: weatherData,
            locationFound: true,
            connectionError: false,
          );
        } catch (e) {
          // 天気APIへの接続エラー
          return WeatherResult(
            data: WeatherData.mock(),
            locationFound: true,
            connectionError: true,
            errorMessage: 'Cannot connect to weather service. Check your internet connection.'
          );
        }
      } else {
        // 都市が見つからなかった場合
        return WeatherResult(
          data: WeatherData.mock(),
          locationFound: false,
          errorMessage: 'City "$locationName" not found'
        );
      }
    } catch (e) {
      // ジオコーディングAPIへの接続エラー
      return WeatherResult(
        data: WeatherData.mock(),
        locationFound: false,
        connectionError: true,
        errorMessage: 'Cannot connect to location service. Check your internet connection.'
      );
    }
  }

  /// 座標から天気データを取得
  Future<WeatherResult> getWeatherByCoordinates(
      double latitude, double longitude, String locationName) async {
    try {
      // APIエンドポイントに座標と必要なパラメータを渡してデータを取得
      final weatherData = await _fetchWeatherByCoordinates(
        latitude,
        longitude,
        locationName
      );

      return WeatherResult(
        data: weatherData,
        locationFound: true,
        connectionError: false,
      );
    } catch (e) {
      // API接続エラー
      return WeatherResult(
        data: WeatherData.mock(),
        locationFound: true,
        connectionError: true,
        errorMessage: 'Cannot connect to weather service. Check your internet connection.'
      );
    }
  }
}
```

### screens/home/home_controller.dart
ユーザー入力と表示データを連携させるController：

```dart
class HomeController {
  // Services
  final WeatherService weatherService = WeatherService();

  // Weather data
  WeatherData? weatherData;
  bool isLoadingWeather = false;

  // エラーメッセージ表示用のヘルパーメソッド
  void _showConnectionError(BuildContext context, String errorMessage, Function() retryAction) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: retryAction,
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  // 位置選択時の処理
  Future<void> onLocationSelected(Location location, BuildContext context) async {
    isLoadingWeather = true;

    // 1. 選択された位置情報を保存
    locationManager.currentLocation = location.name;

    // 2. その位置の天気データを取得
    try {
      final result = await weatherService.getWeatherByCoordinates(
        location.latitude,
        location.longitude,
        location.displayName
      );

      weatherData = result.data;

      // エラー処理
      if (result.connectionError && context.mounted) {
        _showConnectionError(
          context,
          result.errorMessage,
          () => onLocationSelected(location, context)
        );
      }
    } catch (e) {
      // 例外処理
      weatherData = WeatherData.mock();
      _showConnectionError(
        context,
        'Error getting weather data. Please try again later.',
        () => onLocationSelected(location, context)
      );
    }

    isLoadingWeather = false;
  }
}
```

### screens/weather/tab_content_builder.dart
Controllerからのデータを画面表示用に変換：

```dart
class TabContentBuilder {
  /// タブの内容を構築
  static List<Widget> buildTabContents({
    // Location info
    required String currentLocation,
    // Weather data
    WeatherData? weatherData,
    // Other params...
  }) {
    // データが取得できない場合は空の状態を表示
    return [
      // 各タブに適切なデータを渡す、またはnullの場合はエラー状態を表示
      isLoading
          ? _buildLoadingTab()
          : weatherData == null
              ? _buildNoDataTab("No current weather data available")
              : CurrentlyScreen(weather: weatherData.current, ...),

      // 同様に他のタブも条件付きで表示
      // ...
    ];
  }
}
```

## エラー処理の特徴

アプリケーションには以下のエラー処理機能が実装されています：

1. **無効な都市名の処理**:
   - ユーザーが存在しない都市名を入力した場合、「City "XXX" not found. Please enter a valid city name.」というメッセージが表示されます
   - **新機能**: エラーメッセージはオレンジ色のバナーとして画面上部に永続的に表示されます
   - ユーザーは明示的に閉じるボタンを押すか、有効な都市名を入力するまでメッセージが表示され続けます
   - エラー状態でもアプリケーションは操作可能ですが、データは表示されず代わりにエラーメッセージが表示されます

2. **API接続エラーの処理と再試行機能**:
   - 天気情報APIやジオコーディングAPIへの接続が失敗した場合、エラーメッセージが表示されます
   - 「Cannot connect to weather service. Check your internet connection.」のようなメッセージが赤色のバナーとして表示されます
   - **新機能**: 「Retry」ボタンが表示され、ユーザーはワンタップで操作を再試行できます
   - メッセージはAPIへの接続が復旧するか、ユーザーが別の操作を成功させるまで表示され続けます
   - 再試行機能は、都市検索、位置情報取得、候補選択などすべてのネットワーク操作に実装されています
   - エラー状態でもアプリケーションはクラッシュせず、エラーメッセージを表示して機能し続けます

3. **エラー状態の永続的な管理**:
   - HomeControllerクラスにエラー状態とメッセージを管理するためのプロパティを追加
   ```dart
   // Error states
   bool hasError = false;
   String errorMessage = '';
   bool isLocationNotFound = false;
   bool isConnectionError = false;
   ```
   - エラー状態は新しい操作が成功するか、ユーザーが明示的にエラーを閉じるまで保持されます
   - エラー状態のリセットとクリアを管理する専用メソッドを実装

4. **結果クラスを用いたエラー状態の伝達**:
   - `WeatherResult` クラスを使用し、データだけでなくエラー状態や詳細なエラーメッセージも含めて返します
   - エラーの種類（都市が見つからない、接続エラーなど）を区別し、適切なユーザーフィードバックを提供します
   - エラー情報は一箇所（WeatherResult）に集約され、UIとの連携が容易になっています

5. **視覚的フィードバックの区別**:
   - エラーの種類に応じて異なる色のバナーが表示されます
   - 都市が見つからないエラー: オレンジ色 - 警告レベルのエラーとして表示（location_offアイコン付き）
   - 接続エラー: 赤色 - 重大なエラーとして表示（error_outlineアイコン付き）
   - 各エラーには適切なアクションボタン（Dismiss または Retry）が付属しています

6. **位置情報の権限エラー処理**:
   - ユーザーが位置情報へのアクセスを拒否した場合、適切なメッセージが表示されます
   - 位置情報が利用できなくても、手動での都市検索が常に利用可能です

## アーキテクチャの特徴

このアプリケーションは以下のアーキテクチャパターンに従っています：

1. **責任の分離**: 各クラスやメソッドが明確に定義された責任を持ち、単一責任の原則に従っています。
2. **コンポーネントの再利用**: ウィジェットは再利用可能で、関連するロジックをカプセル化しています。
3. **メソッドの分割**: 大きな関数を小さなヘルパーメソッドに分割し、コードの可読性と保守性を高めています。
4. **レスポンシブデザイン**: 様々な画面サイズに対応するためのヘルパーメソッドが組み込まれています。
5. **データフロー管理**: Controllerを通じて選択された位置情報が各タブに伝達される仕組みを実装しています。
6. **堅牢なエラーハンドリング**:
   - アプリケーションは様々なエラーシナリオに対処し、ユーザーに明確なフィードバックを提供します
   - `WeatherResult`クラスによるエラー状態のカプセル化を行い、一貫したエラー処理を実現
   - 共通の`_showConnectionError`ヘルパーメソッドを使用してエラー表示を統一化
   - ユーザーフレンドリーなエラーメッセージと、再試行オプションを提供し、ユーザー体験を向上
7. **エラー表示メカニズム**: ネットワークエラーが発生した場合でも、適切なエラーメッセージを表示し、アプリケーションの継続的な機能を保証します。

## データの流れ

1. 位置情報の選択（検索または現在地）→ HomeController.selectedLocation に保存
2. 選択された位置情報を使用してWeatherServiceでAPI呼び出し → 天気データを取得
3. 取得した天気データをHomeController.weatherDataに保存
4. HomeController → TabContentBuilder → 各スクリーン へと位置情報と天気データが伝達される
5. 各スクリーンでは受け取った位置情報と天気データを表示

## 今後の拡張予定

このプロジェクト構造は、以下のような将来の拡張を見据えています：

1. **APIレスポンスのキャッシュ**: ネットワーク呼び出しを減らすためのローカルキャッシュ機能。
2. **座標から都市名の取得**: 現在の座標からリバースジオコーディングを行い、都市名を表示する機能。
3. **より詳細な天気情報**: 気圧、視界、紫外線指数などの追加データの表示。
4. **通知機能**: 悪天候の警告や毎日の天気予報通知機能。
5. **状態管理の強化**: より複雑なアプリケーション状態を管理するためのProviderやBlocパターンの導入。
6. **ユニットテストの追加**: 各コンポーネントの動作を検証するためのテストコードの追加。
7. **パフォーマンス最適化**: 大量のデータを扱う場合のパフォーマンス向上のための最適化。
8. **UI/UXの改善**: 天気データをより視覚的に分かりやすく表示するためのデザイン改善。
9. **オフライン対応**: インターネット接続がない場合の最後の取得データ表示機能。
10. **さらなるエラー処理の拡張**: 様々なエッジケースを処理するためのエラーハンドリングの充実化。
11. **ユーザー設定**: 温度単位（摂氏/華氏）やデータ更新頻度などのカスタマイズ機能。

## 新機能の詳細：Open-Meteo APIによる都市検索

### Open-Meteo ジオコーディングAPI

このアプリでは、Open-Meteoが提供する無料のジオコーディングAPIを使用して都市名から位置情報を取得しています：

- API URL: `https://geocoding-api.open-meteo.com/v1/search`
- パラメータ:
  - `name`: 検索する場所の名前
  - `count`: 返す結果の最大数
  - `language`: 結果の言語
  - `format`: レスポンス形式 (json)

### 実装のポイント

1. **デバウンス処理**: 検索入力中のAPI呼び出し頻度を制限
   ```dart
   if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
   _searchDebounce = Timer(const Duration(milliseconds: 500), () {
     _searchLocation(_searchController.text);
   });
   ```

2. **検索結果モデル**: APIレスポンスを整理するモデルクラス
   ```dart
   class Location {
     final String name;
     final double latitude;
     final double longitude;
     final String? country;
     final String? admin1; // 都道府県・州など
     // ...
   }
   ```

3. **非同期処理**: APIリクエストの非同期処理
   ```dart
   Future<void> _searchLocation(String query) async {
     // ...
     try {
       final response = await GeocodingService.searchLocation(query: query);
       setState(() {
         _searchResults = response.results;
         // ...
       });
     } catch (e) {
       // エラー処理
     }
   }
   ```

4. **UIのレイヤー構造**: 検索結果リストを適切に表示
   ```dart
   Stack(
     children: [
       // メインコンテンツ
       // ...
       // 検索結果オーバーレイ
       if (_showSearchResults && (_searchResults.isNotEmpty || _isSearching))
         Positioned(
           // 検索結果ウィジェット
         ),
     ],
   )
   ```

## まとめ

Weather Appは、モジュール化された設計とクリーンなコード構造を持つFlutterアプリケーションです。責任の分離とヘルパーメソッドの活用により、コードの可読性と保守性が高められています。最新の追加では、Open-MeteoのジオコーディングAPIを統合して都市検索機能を実装し、ユーザーエクスペリエンスを向上させました。このアプローチにより、将来的な機能追加や変更が容易になります。