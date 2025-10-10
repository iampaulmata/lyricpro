import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricpro_app/core/app.dart';
import 'package:lyricpro_app/core/config/app_env.dart';
import 'package:lyricpro_app/core/supabase/supabase_client_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  await SupabaseBootstrapper.ensureInitialized();
  runApp(const ProviderScope(child: LyricProApp()));
}
