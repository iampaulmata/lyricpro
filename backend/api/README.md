# LyricPro Backend API

This Node.js service acts as the orchestration layer for LyricPro, proxying secure requests to Supabase and enabling future business logic such as sync conflict resolution.

## Requirements

- Node.js 18+
- npm or pnpm
- Running Supabase instance (local Docker or managed)

## Getting Started

1. Copy `.env.example` to `.env` and update values.
2. Install dependencies:

   ```bash
   npm install
   ```

3. Start the development server:

   ```bash
   npm run dev
   ```

4. Build for production:

   ```bash
   npm run build
   npm start
   ```

## Project Structure

- `src/server/app.ts` – Express app factory configuring middleware.
- `src/server/routes` – Modular route handlers (`/health`, `/sync`, ...).
- `src/server/services` – External integrations (Supabase client helper).
- `src/server/config` – Environment schema and configuration utilities.

## Next Steps

- Expand `/sync` endpoints to accept and distribute queued mutations.
- Implement authentication middleware verifying Supabase JWTs.
- Add tests (Jest or Vitest) covering routes and services.
- Dockerize the service for deployment alongside Supabase stack.
