import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeControllerProvider =
    StateNotifierProvider<ThemeController, AppThemeState>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<AppThemeState> {
  ThemeController()
      : super(
          const AppThemeState(
            mode: ThemeMode.system,
            accent: AppAccent.orange,
          ),
        );

  set themeMode(ThemeMode mode) {
    var accent = state.accent;
    if (!accent.allowsMode(mode)) {
      accent = AppAccent.values.firstWhere(
        (candidate) => candidate.allowsMode(mode),
        orElse: () => AppAccent.orange,
      );
    }
    state = state.copyWith(mode: mode, accent: accent);
  }

  void toggleDarkLight() {
    switch (state.mode) {
      case ThemeMode.light:
        themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        themeMode = ThemeMode.light;
        break;
      case ThemeMode.system:
        themeMode = ThemeMode.dark;
        break;
    }
  }

  void setAccent(AppAccent accent) {
    if (accent == state.accent || !accent.allowsMode(state.mode)) {
      return;
    }
    state = state.copyWith(accent: accent);
  }
}

@immutable
class AppThemeState {
  const AppThemeState({
    required this.mode,
    required this.accent,
  });

  final ThemeMode mode;
  final AppAccent accent;

  AppThemeState copyWith({
    ThemeMode? mode,
    AppAccent? accent,
  }) {
    return AppThemeState(
      mode: mode ?? this.mode,
      accent: accent ?? this.accent,
    );
  }
}

enum AppAccent {
  orange(
    label: 'Orange',
    primaryColor: Color(0xFFFF7A1A),
    secondaryColor: Color(0xFFD97706),
    tertiaryColor: Color(0xFFFFA94C),
    allowOnLight: true,
    allowOnDark: true,
  ),
  green(
    label: 'Green',
    primaryColor: Color(0xFF22C55E),
    secondaryColor: Color(0xFF15803D),
    tertiaryColor: Color(0xFF4ADE80),
    allowOnLight: true,
    allowOnDark: true,
  ),
  purple(
    label: 'Purple',
    primaryColor: Color(0xFF8B5CF6),
    secondaryColor: Color(0xFF6D28D9),
    tertiaryColor: Color(0xFFA855F7),
    allowOnLight: true,
    allowOnDark: true,
  ),
  pink(
    label: 'Pink',
    primaryColor: Color(0xFFEC4899),
    secondaryColor: Color(0xFFBE185D),
    tertiaryColor: Color(0xFFF472B6),
    allowOnLight: true,
    allowOnDark: true,
  ),
  red(
    label: 'Red',
    primaryColor: Color(0xFFEF4444),
    secondaryColor: Color(0xFFB91C1C),
    tertiaryColor: Color(0xFFF87171),
    allowOnLight: true,
    allowOnDark: true,
  ),
  yellow(
    label: 'Yellow',
    primaryColor: Color(0xFFFACC15),
    secondaryColor: Color(0xFFEAB308),
    tertiaryColor: Color(0xFFFCD34D),
    allowOnLight: false,
    allowOnDark: true,
  ),
  navy(
    label: 'Navy',
    primaryColor: Color(0xFF1E3A8A),
    secondaryColor: Color(0xFF1D4ED8),
    tertiaryColor: Color(0xFF0F172A),
    allowOnLight: true,
    allowOnDark: false,
  );

  const AppAccent({
    required this.label,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.allowOnLight,
    required this.allowOnDark,
  });

  final String label;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final bool allowOnLight;
  final bool allowOnDark;

  List<Color> get gradient => [primaryColor, secondaryColor];

  bool allowsBrightness(Brightness brightness) {
    return brightness == Brightness.light ? allowOnLight : allowOnDark;
  }

  bool allowsMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => allowOnLight,
      ThemeMode.dark => allowOnDark,
      ThemeMode.system => allowOnLight && allowOnDark,
    };
  }
}
