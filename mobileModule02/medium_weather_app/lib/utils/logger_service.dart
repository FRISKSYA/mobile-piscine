import 'package:logger/logger.dart';

/// シングルトンのロガーサービス
class LoggerService {
  // シングルトンインスタンス
  static final LoggerService _instance = LoggerService._internal();

  // Loggerインスタンス
  late final Logger logger;

  // ファクトリコンストラクタ
  factory LoggerService() {
    return _instance;
  }

  // 内部コンストラクタ
  LoggerService._internal() {
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // 表示するメソッドコールスタックの数
        errorMethodCount: 8, // エラー時に表示するメソッドコールの数
        lineLength: 120, // 行の最大長
        colors: true, // カラー表示の有効化
        printEmojis: true, // 絵文字の表示
        printTime: true, // タイムスタンプの表示
      ),
    );
  }

  // デバッグログ
  void d(String message) {
    logger.d(message);
  }

  // 情報ログ
  void i(String message) {
    logger.i(message);
  }

  // 警告ログ
  void w(String message) {
    logger.w(message);
  }

  // エラーログ
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }
}

// グローバルなロガーインスタンス
final loggerService = LoggerService();