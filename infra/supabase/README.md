# Supabase Local Development

LyricPro targets a self-hostable Supabase stack for authentication, storage, and realtime collaboration. For early development, use the Supabase CLI to run a local stack.

## Prerequisites

- [Supabase CLI](https://supabase.com/docs/guides/cli) installed locally
- Docker Desktop or compatible container runtime

## Quick Start

```bash
supabase start
```

This command launches Postgres, Auth, Rest, Realtime, Storage, and Studio services. Once running, configure the backend API (`backend/api/.env`) with the generated service role key and REST endpoint.

## Project Configuration

- The CLI generates a `.supabase` folder containing your Docker assets and service keys.
- Apply database migrations and seed data via `supabase db push` and `supabase db seed` (coming soon).

## Next Steps

- Add migration scripts derived from the Drift schema once finalized.
- Automate Supabase provisioning for CI environments.
- Document production deployment guidance (managed Supabase or self-hosted).
