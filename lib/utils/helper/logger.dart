import 'package:logger/logger.dart';

class DLoggerHelper {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(

    ),
    level: Level.debug,
  );

  static const String tag = "LCD"; // Gán tag mặc định

  static void debug(String message) {
    _logger.d("[$tag] $message");
  }

  static void info(String message) {
    _logger.i("[$tag] $message");
  }

  static void warning(String message) {
    _logger.w("[$tag] $message");
  }

  static void error(String message, [dynamic errors]) {
    _logger.e("[$tag] $message", error: errors, stackTrace: StackTrace.current);
  }
}
