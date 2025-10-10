import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lyricpro_app/core/config/app_env.dart';
import 'package:lyricpro_app/core/supabase/supabase_client_provider.dart';
import 'package:lyricpro_app/data/models/app_user.dart';



enum AuthProvider {
  google(OAuthProvider.google),
  apple(OAuthProvider.apple),
  facebook(OAuthProvider.facebook);

  const AuthProvider(this.provider);

  final OAuthProvider provider;
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
  final client = ref.watch(supabaseProvider);
  final controller = AuthController(client: client);
  ref.onDispose(controller.dispose);
  return controller;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.value != null;
});

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  String? _readMetadata(Map<String, dynamic>? metadata, String key) {
    if (metadata == null) return null;
    final value = metadata[key];
    return value is String ? value : null;
  }
  AuthController({required SupabaseClient? client})
      : _client = client,
        super(const AsyncValue.loading()) {
    _init();
    if (AppEnv.hasSupabaseCredentials && _client != null) {
      _subscription = _client!.auth.onAuthStateChange.listen((event) {
        final session = event.session;
        final user = session?.user;
        if (user == null) {
          state = const AsyncValue.data(null);
        } else {
          state = AsyncValue.data(_mapUser(user));
        }
      });
    } else {
      state = const AsyncValue.data(null);
    }
  }

  final SupabaseClient? _client;
  StreamSubscription<AuthState>? _subscription;

  Future<void> _init() async {
    if (!AppEnv.hasSupabaseCredentials || _client == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final currentUser = _client!.auth.currentUser;
      state = AsyncValue.data(
        currentUser != null ? _mapUser(currentUser) : null,
      );
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> signIn(AuthProvider provider) async {
    if (!AppEnv.hasSupabaseCredentials) {
      state = AsyncValue.error(
        'Supabase credentials missing. Sign-in unavailable in offline mode.',
        StackTrace.current,
      );
      return;
    }

    if (_client == null) {
      state = AsyncValue.error(
        'Supabase client unavailable. Check configuration.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _client!.auth.signInWithOAuth(provider.provider);
      // Supabase will trigger auth state stream; await update there.
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  AppUser _mapUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email,
      name: _readMetadata(user.userMetadata, 'full_name'),
      avatarUrl: _readMetadata(user.userMetadata, 'avatar_url'),
    );
  }
}
