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

## ディレクトリ構造

```
lib/
├── config/             # アプリ設定・定数・テーマ
├── models/             # データモデル
│   └── geocoding/      # ジオコーディングAPI用モデル
├── screens/            # 画面
├── services/           # API・バックエンドサービス
│   ├── location_service.dart     # 位置情報サービス
│   └── geocoding_service.dart    # ジオコーディングAPIサービス
├── utils/              # ユーティリティ関数 (将来の拡張用)
├── widgets/            # 再利用可能なウィジェット
│   ├── location_search_results.dart  # 検索結果ウィジェット
│   └── search_bar.dart              # 検索バーウィジェット
└── main.dart           # アプリケーションのエントリーポイント
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

### config/constants.dart

アプリ全体で使用する定数を定義します。タブ名や最大フォントサイズなどが含まれています。

### config/theme.dart

アプリケーションのテーマ設定を定義します。色、フォント、スタイルなどのUIの設定と、レスポンシブデザインのためのユーティリティメソッドが含まれています。

### screens/home_screen.dart

アプリケーションのメイン画面であり、タブバーとタブコンテンツを管理します。検索機能と位置情報機能も実装しています。ユーザー入力の処理とタブコンテンツの作成を別々のメソッドに分離しています。位置情報の取得と表示を担当します。

### services/location_service.dart

位置情報サービスを提供するクラスです。デバイスのGPS機能を利用して現在位置の座標を取得したり、位置情報の権限を管理したりします。主な機能は以下の通りです：

1. 現在位置の取得: `getCurrentLocation()`メソッドを使用してデバイスの現在の位置情報を取得します。
2. 位置情報の許可状態の確認: `isLocationPermissionGranted()`メソッドで位置情報の権限が与えられているかを確認します。
3. 位置情報の許可のリクエスト: `requestLocationPermission()`メソッドで位置情報の権限をユーザーにリクエストします。
4. 座標のフォーマット: `formatPosition()`メソッドで位置情報を人間が読みやすい形式に変換します。

### widgets/tab_content.dart

タブコンテンツの共通レイアウトを定義する再利用可能なウィジェットです。UI要素の構築を複数のヘルパーメソッドに分離し、コードの可読性と保守性を高めています。位置情報の座標などの追加情報と読み込み状態を表示する機能が追加されました。

## 使い方

1. アプリを起動すると、3つのタブ（Currently、Today、Weekly）を持つ画面が表示されます。
2. 上部の検索バーに場所の名前を入力し、キーボードの実行ボタンをタップすると、その場所の情報が全タブに表示されます。
3. 右上の位置情報ボタンをタップすると、アプリは位置情報の許可をリクエストします。
   - 許可された場合は、現在位置の座標（緯度と経度）がタブに表示されます。
   - 許可が拒否された場合は、エラーメッセージが表示され、ユーザーは手動で場所を検索する必要があります。
4. 位置情報の取得中は、ローディングインジケーターが表示されます。
5. 下部のタブバーで各タブを切り替えることができます。

## アーキテクチャの特徴

このアプリケーションは以下のアーキテクチャパターンに従っています：

1. **責任の分離**: 各クラスやメソッドが明確に定義された責任を持ち、単一責任の原則に従っています。
2. **コンポーネントの再利用**: ウィジェットは再利用可能で、関連するロジックをカプセル化しています。
3. **メソッドの分割**: 大きな関数を小さなヘルパーメソッドに分割し、コードの可読性と保守性を高めています。
4. **レスポンシブデザイン**: 様々な画面サイズに対応するためのヘルパーメソッドが組み込まれています。

## 今後の拡張予定

このプロジェクト構造は、以下のような将来の拡張を見据えています：

1. **実際の天気API統合**: 取得した座標や検索した場所の実際の天気データを取得・表示する機能。
2. **座標から都市名の取得**: 現在の座標からリバースジオコーディングを行い、都市名を表示する機能。
3. **位置情報の精度向上**: 位置情報の精度を向上させるための設定やオプションの追加。
4. **状態管理の強化**: より複雑なアプリケーション状態を管理するためのProviderやBlocパターンの導入。
5. **ユニットテストの追加**: 各コンポーネントの動作を検証するためのテストコードの追加。
6. **パフォーマンス最適化**: 大量のデータを扱う場合のパフォーマンス向上のための最適化。

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