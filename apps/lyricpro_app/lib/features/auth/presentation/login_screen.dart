import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lyricpro_app/features/dashboard/presentation/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String routeName = 'login';

  @override
  Widget build(BuildContext context) {
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
                    _AuthButtonsColumn(width: contentWidth),
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
  const _AuthButtonsColumn({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthButton(
          width: width,
          icon: Icons.account_circle_outlined,
          label: 'Continue with Google',
          onPressed: () {},
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        const SizedBox(height: 16),
        _AuthButton(
          width: width,
          icon: Icons.facebook_outlined,
          label: 'Continue with Facebook',
          onPressed: () {},
          backgroundColor: const Color(0xFF1778F2),
        ),
        const SizedBox(height: 16),
        _AuthButton(
          width: width,
          icon: Icons.email_outlined,
          label: 'Continue with Email',
          onPressed: () {},
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
  final VoidCallback onPressed;
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
