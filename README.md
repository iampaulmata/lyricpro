# LyricPro

Cross-platform, open-source lyric and chord management tool for live performers. This repository houses the Flutter client, backend orchestration service, and supporting documentation.

## Repository Layout

- `apps/lyricpro_app` – Flutter client scaffolding (Riverpod, GoRouter, FlexColorScheme).
- `backend/api` – Node.js/Express service prepared to coordinate Supabase sync logic.
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

3. Spin up the backend API:

   ```bash
   cd backend/api
   cp .env.example .env
   npm install
   npm run dev
   ```

4. Connect the backend to a Supabase instance (managed or self-hosted) and wire the service role credentials in `.env`.

## Next Steps

- Implement feature modules outlined in the product backlog.
- Add automated testing workflows (GitHub Actions) for client and backend packages.
- Introduce infrastructure scripts for provisioning Supabase and CI/CD pipelines.
