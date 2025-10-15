Local Supabase setup and testing
================================

This document explains how to use the local Supabase instance for development and how to apply the project's migration and create a test user.

Prereqs
-------
- Docker installed and running
- Supabase CLI installed and `supabase start` running
- `apps/lyricpro_app/.env` containing SUPABASE_URL and SUPABASE_ANON_KEY

Apply the migration (profiles table)
-----------------------------------
You can apply the SQL migration using Supabase Studio or the CLI:

Via Supabase Studio:
1. Open the Studio (the CLI prints the Studio URL when starting; typically http://localhost:54322)
2. Go to SQL Editor and paste the contents of `db/migrations/001_create_profiles.sql` and run it.

Via the CLI:
```bash
# from the repo root, assuming supabase started in ~/supabase-local
supabase projects sql "$(< db/migrations/001_create_profiles.sql)"
```

Create a test user
------------------
Use the included script:

```bash
SUPABASE_URL=http://127.0.0.1:54321 \
SUPABASE_ANON_KEY=<your_anon_key_here> \
  ./scripts/create_test_user.sh
```

This will create a user with email `test@example.com` and password `Password123!`.

Notes
-----
- Remember local anon keys are still sensitive: do not commit them to remote repositories.
- For OAuth or external provider testing, configure provider settings in Supabase Studio.
