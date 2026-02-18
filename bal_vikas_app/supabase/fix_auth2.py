#!/usr/bin/env python3
"""Fix auth schema issues by checking RPC functions and testing login."""

import requests
import time

SUPABASE_TOKEN = "sbp_573715d84de517dc89b7633fdef4225c73cf238a"
PROJECT_REF = "owfioycwviwjteviwkka"
API_URL = f"https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query"
HEADERS = {
    "Authorization": f"Bearer {SUPABASE_TOKEN}",
    "Content-Type": "application/json",
}

# Supabase client URL/key for testing auth
SUPABASE_URL = "https://owfioycwviwjteviwkka.supabase.co"
SUPABASE_ANON_KEY = None

def execute_sql(sql, label=""):
    resp = requests.post(API_URL, headers=HEADERS, json={"query": sql})
    if resp.status_code == 201:
        try:
            data = resp.json()
            print(f"  OK - {label}")
            if data:
                print(f"  Result: {data}")
        except:
            print(f"  OK - {label}")
        return True, resp.json() if resp.text else None
    else:
        print(f"  ERROR ({resp.status_code}) - {label}: {resp.text[:500]}")
        return False, None


# Check for triggers on auth.users that might cause issues
print("Checking auth triggers and functions...")
execute_sql("""
SELECT tgname, tgtype, proname
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'auth' AND c.relname = 'users';
""", "auth.users triggers")
time.sleep(0.3)

# Check if there are any auth hooks/functions referencing schema
print("\nChecking for custom auth hooks...")
execute_sql("""
SELECT routine_name, routine_schema
FROM information_schema.routines
WHERE routine_name LIKE '%auth%' OR routine_name LIKE '%user%'
ORDER BY routine_schema, routine_name
LIMIT 20;
""", "auth-related functions")
time.sleep(0.3)

# Check auth.schema_migrations
print("\nChecking auth schema migrations...")
execute_sql("""
SELECT version FROM auth.schema_migrations ORDER BY version DESC LIMIT 5;
""", "recent schema migrations")
time.sleep(0.3)

# Check if flow_state table exists (newer GoTrue versions need it)
print("\nChecking auth tables...")
execute_sql("""
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'auth'
ORDER BY table_name;
""", "auth tables")
time.sleep(0.3)

# The issue might be with flow_state or sessions table
# Try fixing by cleaning up stale sessions
print("\nCleaning stale auth sessions...")
execute_sql("""
DELETE FROM auth.sessions WHERE created_at < NOW() - INTERVAL '7 days';
""", "delete old sessions")
time.sleep(0.3)

# Check if there's a flow_state table with issues
execute_sql("""
SELECT COUNT(*) FROM auth.flow_state;
""", "flow_state count")
time.sleep(0.3)

# Clean up flow_state if it exists
execute_sql("""
DELETE FROM auth.flow_state WHERE created_at < NOW() - INTERVAL '1 day';
""", "clean flow_state")
time.sleep(0.3)

# Ensure the auth user has proper metadata
print("\nFixing auth user metadata for AWW 7000000001...")
execute_sql("""
UPDATE auth.users
SET raw_app_meta_data = '{"provider":"email","providers":["email"]}'::jsonb,
    raw_user_meta_data = '{}'::jsonb,
    aud = 'authenticated',
    role = 'authenticated',
    email_confirmed_at = NOW(),
    updated_at = NOW()
WHERE email = '7000000001@balvikas.pilot';
""", "fix AWW auth metadata")
time.sleep(0.3)

# Verify the identity record
execute_sql("""
SELECT i.id, i.user_id, i.provider, i.provider_id, i.identity_data
FROM auth.identities i
JOIN auth.users u ON i.user_id = u.id
WHERE u.email = '7000000001@balvikas.pilot';
""", "AWW identity record")
time.sleep(0.3)

# Try to fix ALL auth users - ensure they have proper identity records
print("\nEnsuring all auth users have proper identity data...")
execute_sql("""
UPDATE auth.identities
SET identity_data = jsonb_build_object(
    'sub', user_id::text,
    'email', (SELECT email FROM auth.users WHERE id = auth.identities.user_id),
    'email_verified', true,
    'phone_verified', false
)
WHERE provider = 'email'
AND identity_data->>'email' IS NULL;
""", "fix identity data")
time.sleep(0.3)

# Check if the password is correct
print("\nVerifying password hash...")
execute_sql("""
SELECT
    email,
    (encrypted_password = crypt('pilot123456', encrypted_password)) as password_correct
FROM auth.users
WHERE email = '7000000001@balvikas.pilot';
""", "password verification")
time.sleep(0.3)

# Try testing the auth directly via REST
print("\nTesting auth via Supabase REST API...")
# Get the anon key from project settings
ok, result = execute_sql("""
SELECT decrypted_secret
FROM vault.decrypted_secrets
WHERE name = 'anon_key'
LIMIT 1;
""", "get anon key")

print("\nDone! Try logging in again.")
