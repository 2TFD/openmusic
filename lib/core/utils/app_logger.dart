import 'dart:developer' as dev;

class AppLogger {
  static Future<void> log(String message) async {
    dev.log(message, name: 'AppLogger');
  }
}
