import 'package:logger/logger.dart';

/// Singleton logger service
class LoggerService {
  // Singleton instance
  static final LoggerService _instance = LoggerService._internal();

  // Logger instance
  late final Logger logger;

  // Factory constructor
  factory LoggerService() {
    return _instance;
  }

  // Internal constructor
  LoggerService._internal() {
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to display in the stack
        errorMethodCount: 8, // Number of method calls to display for errors
        lineLength: 120, // Maximum line length
        colors: true, // Enable colors
        printEmojis: true, // Enable emojis
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart // Timestamp format
      ),
    );
  }

  // Debug log
  void d(String message) {
    logger.d(message);
  }

  // Info log
  void i(String message) {
    logger.i(message);
  }

  // Warning log
  void w(String message) {
    logger.w(message);
  }

  // Error log
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }
}

// Global logger instance
final loggerService = LoggerService();