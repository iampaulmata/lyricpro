-- Migration: create profiles table
-- Run this in Supabase Studio SQL editor or via the CLI's SQL runner

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  created_at timestamptz default now()
);

-- Optional: grant select/insert to anon role if you want public writes (be careful in prod)
-- grant select, insert on public.profiles to anon;
