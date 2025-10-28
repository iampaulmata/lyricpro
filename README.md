# LyricPro

Cross-platform, open-source lyric and chord management tool for live performers. This repository currently focuses on the local-first Flutter client and supporting documentation.

## Repository Layout

- `apps/lyricpro_app` – Flutter client scaffolding (Riverpod, GoRouter, FlexColorScheme).
- `backend/api` – (Future) service stubs kept for eventual cloud sync exploration.
- `docs` – Architecture overview and planning materials.
- `infra` – (Reserved) infrastructure templates and deployment assets.

## Getting Started

1. Review `docs/architecture.md` for the product and technical overview.
2. Set up the Flutter client in `apps/lyricpro_app`:

   ```bash
   cd apps/lyricpro_app
   flutter pub get
   flutter run
   ```

## Next Steps

- Expand local library management features outlined in the product backlog.
- Add automated testing workflows (GitHub Actions) for the client package.
- Revisit hosted sync/infrastructure plans once collaboration returns to the roadmap.
