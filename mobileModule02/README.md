# Weather App - 位置情報の実装

## 第IV章 演習00: 現在地の取得

このプロジェクトでは、モバイル天気アプリに位置情報機能を実装しました。この機能により、ユーザーがアプリケーションを起動した時、または位置情報ボタンをクリックした時に、デバイスのGPSから現在地の座標を取得し表示します。

## プロジェクト構造

```
weather_app/
├── lib/
│   ├── config/                # アプリ設定・定数・テーマ
│   │   ├── constants.dart    # アプリ全体で使用する定数
│   │   └── theme.dart        # アプリのテーマ設定
│   ├── models/               # データモデル
│   │   ├── forecast.dart     # 予報データモデル
│   │   └── weather.dart      # 天気データモデル
│   ├── screens/              # 画面
│   │   ├── currently_screen.dart  # 現在の天気画面
│   │   ├── home_screen.dart      # メインホーム画面
│   │   ├── today_screen.dart     # 今日の天気画面
│   │   └── weekly_screen.dart    # 週間予報画面
│   ├── services/             # APIおよびサービス
│   │   ├── location_service.dart  # 位置情報サービス
│   │   └── weather_service.dart   # 天気情報サービス
│   ├── widgets/              # 再利用可能なウィジェット
│   │   ├── search_bar.dart      # 検索バーウィジェット
│   │   ├── tab_content.dart     # タブコンテンツウィジェット
│   │   └── weather_tab_bar.dart # タブバーウィジェット
│   └── main.dart            # アプリのエントリーポイント
```

## 実装内容

### 1. 追加したパッケージ
- **geolocator**: デバイスのGPS機能を使って位置情報を取得するためのパッケージです。

### 2. 主要ファイルと機能

#### `location_service.dart`
位置情報関連の機能を提供するサービスクラスです。

```dart
class LocationService {
  // 現在位置の座標を取得
  Future<Position> getCurrentLocation() async { ... }
  
  // 位置情報の権限状態を確認
  Future<bool> isLocationPermissionGranted() async { ... }
  
  // 位置情報の権限をリクエスト
  Future<bool> requestLocationPermission() async { ... }
  
  // 座標を表示用にフォーマット
  String formatPosition(Position position) { ... }
}
```

#### `home_screen.dart`
位置情報ボタンを押した時の処理を実装しています。

```dart
void _onLocationPressed() async {
  // ローディング状態を表示
  setState(() {
    _isLoadingLocation = true;
    _isUsingGeolocation = true;
  });
  
  try {
    // 位置情報の権限確認
    bool hasPermission = await _locationService.isLocationPermissionGranted();
    
    if (!hasPermission) {
      // 権限リクエスト処理...
    }
    
    // 現在位置の取得
    Position position = await _locationService.getCurrentLocation();
    String formattedPosition = _locationService.formatPosition(position);
    
    // 状態更新...
  } catch (e) {
    // エラー処理...
  }
}
```

#### `tab_content.dart`
取得した位置情報の座標を表示するウィジェットです。

```dart
class TabContent extends StatelessWidget {
  // ... 他のプロパティ
  final String extraInfo;  // 座標情報を表示するためのプロパティ
  final bool isLoading;    // 読み込み中表示用のプロパティ
  
  // ... 他のメソッド
  
  // 座標情報を表示するウィジェット
  Widget _buildExtraInfo(BuildContext context) { ... }
  
  // ローディングインジケーターを表示するウィジェット
  Widget _buildLoadingIndicator(BuildContext context) { ... }
}
```

### 3. プラットフォーム設定

#### Android設定
`AndroidManifest.xml`に位置情報の権限を追加:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS設定
`Info.plist`に位置情報使用の説明を追加:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open to fetch weather for your current location.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background to fetch weather for your current location.</string>
```

## 機能の挙動

1. ユーザーが位置情報ボタンをタップすると、アプリは位置情報の権限をチェックします
2. 権限が付与されていない場合は、システムの権限リクエストダイアログが表示されます
3. 権限が許可された場合：
   - ローディングインジケーターが表示されます
   - デバイスのGPSから現在位置の座標が取得されます
   - 座標情報（緯度・経度）が各タブに表示されます
4. 権限が拒否された場合：
   - エラーメッセージが表示されます
   - ユーザーは引き続き検索バーを使用して都市名を入力できます

## エラーハンドリング

位置情報に関連する以下のエラーケースを処理しています：
- 位置情報サービスが無効の場合
- 位置情報の権限が拒否された場合
- 位置情報の権限が永続的に拒否された場合
- 位置情報の取得中にエラーが発生した場合