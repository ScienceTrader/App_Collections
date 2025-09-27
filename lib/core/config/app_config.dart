import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class AppConfig {
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
  
  static LogLevel get logLevel {
    if (isDevelopment) return LogLevel.debug;
    return LogLevel.error;
  }
  
  static bool shouldLog(LogLevel level) {
    return level.index >= logLevel.index;
  }
}