import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // fall back to defaults if .env is missing (e.g., CI or first run)
    }
  }

  static String get supabaseUrl =>
      (() {
        try {
          return dotenv.get('SUPABASE_URL', fallback: '');
        } catch (_) {
          // If dotenv wasn't initialized yet, fall back to empty.
          return '';
        }
      })();

  static String get supabaseAnonKey =>
      (() {
        try {
          return dotenv.get('SUPABASE_ANON_KEY', fallback: '');
        } catch (_) {
          // If dotenv wasn't initialized yet, fall back to empty.
          return '';
        }
      })();

  static bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
