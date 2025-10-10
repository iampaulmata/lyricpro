import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lyricpro_app/core/config/app_env.dart';

final supabaseProvider = Provider<SupabaseClient?>((ref) {
  if (!AppEnv.hasSupabaseCredentials) {
    return null;
  }
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

class SupabaseBootstrapper {
  SupabaseBootstrapper._();

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    if (!AppEnv.hasSupabaseCredentials) {
      _initialized = true;
      return;
    }

    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );

    _initialized = true;
  }
}
