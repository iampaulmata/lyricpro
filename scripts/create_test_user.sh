#!/usr/bin/env bash
set -euo pipefail

# This script creates a test user in a local Supabase instance.
# Usage:
# SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_ANON_KEY=<anon_key> ./scripts/create_test_user.sh

SUPABASE_URL=${SUPABASE_URL:-}
ANON_KEY=${SUPABASE_ANON_KEY:-}

if [[ -z "$SUPABASE_URL" || -z "$ANON_KEY" ]]; then
  echo "SUPABASE_URL and SUPABASE_ANON_KEY must be set (export them or prefix the command)"
  exit 1
fi

email="test@example.com"
password="Password123!"

echo "Creating test user: $email"

payload=$(jq -n --arg e "$email" --arg p "$password" '{email: $e, password: $p}')

resp=$(curl -s -w "\n%{http_code}" -X POST "$SUPABASE_URL/auth/v1/signup" \
  -H "Content-Type: application/json" \
  -H "apikey: $ANON_KEY" \
  -d "$payload")

body=$(echo "$resp" | sed '
$!{N;};$p' | sed '$d' || true)
status=$(echo "$resp" | tail -n1)

echo "HTTP status: $status"
echo "Response body:"
echo "$body" | jq || true

if [[ "$status" =~ ^2 ]]; then
  echo "Test user created. Email: $email Password: $password"
else
  echo "Failed to create user (status $status). Check Supabase Studio -> Authentication -> Users."
fi
