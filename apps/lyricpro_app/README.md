# LyricPro Flutter Client

This Flutter application delivers the cross-platform LyricPro client described in the architecture doc. The project is prepared for Riverpod-based state management, GoRouter navigation, and FlexColorScheme theming.

## Requirements

- Flutter SDK 3.16+ (with Dart 3.2+)
- Android/iOS/desktop tooling as needed per platform

## Getting Started

```bash
flutter pub get
flutter run
```

To run tests:

```bash
flutter test
```

## Project Structure

- `lib/core` – global router, theming, and app bootstrapping.
- `lib/features` – feature-first folder structure; begins with the Home screen.
- `test` – placeholder smoke test to be expanded with widget and integration coverage.

## Next Steps

1. Flesh out domain models and providers for library/set list features.
2. Add localization scaffolding and accessibility presets.
3. Integrate sync services once backend endpoints are ready.
