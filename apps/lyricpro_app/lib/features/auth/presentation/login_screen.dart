import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/core/config/app_env.dart';
import 'package:lyricpro_app/data/models/app_user.dart';
import 'package:lyricpro_app/data/services/auth_service.dart';
import 'package:lyricpro_app/data/services/sync_service.dart';
import 'package:lyricpro_app/features/dashboard/presentation/dashboard_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const String routeName = 'login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseEnabled = AppEnv.hasSupabaseCredentials;

    AsyncValue<AppUser?> authState = const AsyncValue.data(null);
    bool isLoading = false;

    if (supabaseEnabled) {
      ref.listen<AsyncValue<AppUser?>>(authControllerProvider, (previous, next) {
        next.when(
          data: (user) {
            if (user != null) {
              final syncController = ref.read(syncControllerProvider.notifier);
              syncController.scheduleBackgroundSync();
              syncController.processQueue();
              context.goNamed(DashboardScreen.routeName);
            }
          },
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign-in failed: $error')),
            );
          },
          loading: () {},
        );
      });

      authState = ref.watch(authControllerProvider);
      isLoading = authState.isLoading;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double contentWidth =
                    constraints.maxWidth.clamp(320.0, 420.0);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/LyricPro_icon.png',
                      height: 108,
                      semanticLabel: 'LyricPro logo',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to LyricPro',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Keep your set lists, lyrics, and stage flow in sync. Choose how you want to get started.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (supabaseEnabled)
                      _AuthButtonsColumn(
                        width: contentWidth,
                        isLoading: isLoading,
                        onSignIn: (provider) {
                          ref
                              .read(authControllerProvider.notifier)
                              .signIn(provider);
                        },
                      ),
                    if (!supabaseEnabled)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          'Cloud sign-in is disabled. Add Supabase credentials to enable account sync.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (supabaseEnabled && authState.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          authState.error.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: contentWidth,
                      child: SwitchListTile.adaptive(
                        value: true,
                        onChanged: (_) {},
                        title: const Text('Remember my last login'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: contentWidth,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.goNamed(DashboardScreen.routeName);
                        },
                        icon: const Icon(Icons.airplanemode_inactive),
                        label: const Text('Continue in offline mode'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {},
                      child: const Text('How LyricPro works'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButtonsColumn extends StatelessWidget {
  const _AuthButtonsColumn({
    required this.width,
    required this.isLoading,
    required this.onSignIn,
  });

  final double width;
  final bool isLoading;
  final void Function(AuthProvider provider) onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthButton(
          width: width,
          icon: Icons.account_circle_outlined,
          label: 'Continue with Google',
          onPressed: isLoading ? null : () => onSignIn(AuthProvider.google),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        const SizedBox(height: 16),
        _AuthButton(
          width: width,
          icon: Icons.facebook_outlined,
          label: 'Continue with Facebook',
          onPressed: isLoading ? null : () => onSignIn(AuthProvider.facebook),
          backgroundColor: const Color(0xFF1778F2),
        ),
        const SizedBox(height: 16),
        _AuthButton(
          width: width,
          icon: Icons.apple,
          label: 'Continue with Apple',
          onPressed: isLoading ? null : () => onSignIn(AuthProvider.apple),
        ),
      ],
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.width,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  final double width;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          textStyle: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
