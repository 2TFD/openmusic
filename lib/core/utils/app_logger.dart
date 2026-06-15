import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppLogger {
  static String get _token => dotenv.env['TG_BOT_TOKEN'] ?? '';
  static String get _chatId => dotenv.env['TG_CHAT_ID'] ?? '';

  static Future<void> log(String message) async {
    try {
      await Dio().post(
        'https://api.telegram.org/bot$_token/sendMessage',
        data: {'chat_id': _chatId, 'text': message},
      );
    } catch (_) {}
  }
}
