#!/usr/bin/env python3
"""Diagnose and fix auth user issues."""

import requests
import time

SUPABASE_TOKEN = "sbp_573715d84de517dc89b7633fdef4225c73cf238a"
PROJECT_REF = "owfioycwviwjteviwkka"
API_URL = f"https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query"
HEADERS = {
    "Authorization": f"Bearer {SUPABASE_TOKEN}",
    "Content-Type": "application/json",
}


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
        return True
    else:
        print(f"  ERROR ({resp.status_code}) - {label}: {resp.text[:500]}")
        return False


# Step 1: Check counts
print("Step 1: Checking current state...")
execute_sql("SELECT COUNT(*) as total FROM auth.users;", "auth.users count")
time.sleep(0.3)
execute_sql("SELECT COUNT(*) as total FROM auth.identities;", "auth.identities count")
time.sleep(0.3)
execute_sql("SELECT COUNT(*) as total FROM public.users;", "public.users count")
time.sleep(0.3)
execute_sql("SELECT COUNT(*) as with_auth FROM public.users WHERE auth_uid IS NOT NULL;", "users with auth_uid")
time.sleep(0.3)
execute_sql("""
SELECT role, COUNT(*) as total, COUNT(auth_uid) as with_auth
FROM public.users GROUP BY role ORDER BY role;
""", "users by role")
time.sleep(0.3)

# Step 2: Check for the specific AWW user
print("\nStep 2: Check AWW user 7000000001...")
execute_sql("""
SELECT u.id, u.phone, u.name, u.role, u.auth_uid, u.awc_id
FROM public.users u WHERE u.phone = '7000000001';
""", "AWW user record")
time.sleep(0.3)

execute_sql("""
SELECT au.id, au.email, au.created_at
FROM auth.users au WHERE au.email = '7000000001@balvikas.pilot';
""", "auth user for 7000000001")
time.sleep(0.3)

# Step 3: Check for duplicate emails in auth.users
print("\nStep 3: Check for duplicates...")
execute_sql("""
SELECT email, COUNT(*) as cnt FROM auth.users
WHERE email LIKE '%@balvikas.pilot'
GROUP BY email HAVING COUNT(*) > 1
LIMIT 10;
""", "duplicate auth emails")
time.sleep(0.3)

# Step 4: Check for orphaned auth users (no matching public.users)
execute_sql("""
SELECT COUNT(*) as orphaned FROM auth.users au
WHERE au.email LIKE '%@balvikas.pilot'
AND NOT EXISTS (
    SELECT 1 FROM public.users u WHERE u.auth_uid = au.id
);
""", "orphaned auth users")
time.sleep(0.3)

# Step 5: Check if there are auth triggers causing issues
print("\nStep 4: Check auth triggers...")
execute_sql("""
SELECT trigger_name, event_manipulation, action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'auth' AND event_object_table = 'users'
LIMIT 10;
""", "auth triggers")
