#!/usr/bin/env python3
"""
Recreate all auth users via GoTrue signup API instead of direct SQL INSERT.
Direct SQL INSERT into auth.users causes "Database error querying schema" on login.
GoTrue signup API creates users properly with all internal GoTrue expectations.
"""

import requests
import json
import time
import sys

SUPABASE_TOKEN = "sbp_573715d84de517dc89b7633fdef4225c73cf238a"
PROJECT_REF = "owfioycwviwjteviwkka"
SQL_API_URL = f"https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query"
SQL_HEADERS = {
    "Authorization": f"Bearer {SUPABASE_TOKEN}",
    "Content-Type": "application/json",
}

SUPABASE_URL = "https://owfioycwviwjteviwkka.supabase.co"
ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93ZmlveWN3dml3anRldml3a2thIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2MzE0ODEsImV4cCI6MjA4NjIwNzQ4MX0.AyO5t28pL0N5tkukmnOdWLqINgy9_0jKXvpLCX3QYr8"
PASSWORD = "pilot123456"


def run_sql(sql, label=""):
    resp = requests.post(SQL_API_URL, headers=SQL_HEADERS, json={"query": sql})
    if resp.status_code == 201:
        try:
            return True, resp.json()
        except:
            return True, None
    else:
        print(f"  SQL ERROR ({label}): {resp.text[:300]}")
        return False, None


def signup_user(email):
    """Create auth user via GoTrue signup API."""
    resp = requests.post(
        f"{SUPABASE_URL}/auth/v1/signup",
        headers={"apikey": ANON_KEY, "Content-Type": "application/json"},
        json={"email": email, "password": PASSWORD},
    )
    if resp.status_code == 200:
        data = resp.json()
        return data["user"]["id"]
    else:
        # User might already exist (from testuser999 or the AWW we already fixed)
        if "already registered" in resp.text.lower() or resp.status_code == 422:
            return None  # Skip
        print(f"  Signup FAILED for {email}: {resp.status_code} {resp.text[:200]}")
        return None


def main():
    # Step 1: Get all public.users who need auth accounts
    print("Step 1: Getting all users who need auth recreation...")
    ok, data = run_sql("""
        SELECT id, phone, auth_uid, role
        FROM public.users
        WHERE phone IS NOT NULL
        ORDER BY
            CASE role
                WHEN 'SENIOR_OFFICIAL' THEN 1
                WHEN 'DW' THEN 2
                WHEN 'CDPO' THEN 3
                WHEN 'SUPERVISOR' THEN 4
                WHEN 'AWW' THEN 5
                ELSE 6
            END,
            phone;
    """, "get all users")

    if not ok or not data:
        print("Failed to get users!")
        sys.exit(1)

    all_users = data
    print(f"Total users to process: {len(all_users)}")

    # Separate into officials (AWW, Supervisor, CDPO, DW, Senior) and parents
    officials = [u for u in all_users if u['role'] in ('AWW', 'SUPERVISOR', 'CDPO', 'DW', 'SENIOR_OFFICIAL')]
    parents = [u for u in all_users if u['role'] not in ('AWW', 'SUPERVISOR', 'CDPO', 'DW', 'SENIOR_OFFICIAL')]

    print(f"Officials: {len(officials)}, Parents: {len(parents)}")

    # Step 2: Delete ALL manually-created auth users (except the ones already created via API)
    print("\nStep 2: Cleaning up all manually-created auth users...")

    # Get IDs of API-created users (they work fine, don't delete them)
    ok, api_users = run_sql("""
        SELECT id, email FROM auth.users
        WHERE email IN ('testuser999@balvikas.pilot', '7000000001@balvikas.pilot');
    """, "get API-created users")

    api_user_ids = set()
    if api_users:
        api_user_ids = {u['id'] for u in api_users}
        print(f"  Preserving {len(api_user_ids)} API-created users")

    # Delete manually-created identities and users (but preserve API-created ones)
    if api_user_ids:
        exclude_ids = "','".join(api_user_ids)
        run_sql(f"""
            DELETE FROM auth.identities WHERE user_id NOT IN ('{exclude_ids}');
        """, "delete old identities")
        time.sleep(0.5)

        run_sql(f"""
            DELETE FROM auth.sessions WHERE user_id NOT IN ('{exclude_ids}');
        """, "delete old sessions")
        time.sleep(0.5)

        run_sql(f"""
            DELETE FROM auth.refresh_tokens WHERE instance_id NOT IN (
                SELECT instance_id FROM auth.users WHERE id IN ('{exclude_ids}')
            ) OR session_id NOT IN (
                SELECT id FROM auth.sessions
            );
        """, "delete old refresh tokens")
        time.sleep(0.5)

        run_sql(f"""
            DELETE FROM auth.users WHERE id NOT IN ('{exclude_ids}');
        """, "delete old auth users")
    else:
        run_sql("DELETE FROM auth.identities;", "delete all identities")
        time.sleep(0.3)
        run_sql("DELETE FROM auth.sessions;", "delete all sessions")
        time.sleep(0.3)
        run_sql("DELETE FROM auth.refresh_tokens;", "delete all refresh tokens")
        time.sleep(0.3)
        run_sql("DELETE FROM auth.users;", "delete all auth users")

    time.sleep(1)

    # Null out all auth_uids in public.users (except already fixed ones)
    run_sql("""
        UPDATE public.users SET auth_uid = NULL
        WHERE phone != '7000000001';
    """, "null out auth_uids")
    time.sleep(0.5)

    # Step 3: Recreate officials via GoTrue signup API
    print(f"\nStep 3: Creating {len(officials)} official auth users via GoTrue API...")
    success_count = 0
    fail_count = 0
    skip_count = 0

    for i, user in enumerate(officials):
        phone = user['phone']
        email = f"{phone}@balvikas.pilot"
        user_id = user['id']

        # Skip AWW 7000000001 (already recreated via API)
        if phone == '7000000001':
            skip_count += 1
            continue

        new_auth_uid = signup_user(email)

        if new_auth_uid:
            # Link to public.users
            ok, _ = run_sql(f"""
                UPDATE public.users SET auth_uid = '{new_auth_uid}' WHERE id = {user_id};
            """, f"link {phone}")
            if ok:
                success_count += 1
            else:
                fail_count += 1
        else:
            fail_count += 1

        if (i + 1) % 20 == 0:
            print(f"  Progress: {i+1}/{len(officials)} (OK:{success_count} Fail:{fail_count} Skip:{skip_count})")

        # Rate limiting - GoTrue has rate limits
        time.sleep(0.3)

    print(f"  Officials done: OK={success_count}, Fail={fail_count}, Skip={skip_count}")

    # Step 4: Recreate parents via GoTrue signup API
    print(f"\nStep 4: Creating {len(parents)} parent auth users via GoTrue API...")
    parent_success = 0
    parent_fail = 0

    for i, user in enumerate(parents):
        phone = user['phone']
        email = f"{phone}@balvikas.pilot"
        user_id = user['id']

        new_auth_uid = signup_user(email)

        if new_auth_uid:
            ok, _ = run_sql(f"""
                UPDATE public.users SET auth_uid = '{new_auth_uid}' WHERE id = {user_id};
            """, f"link parent {phone}")
            if ok:
                parent_success += 1
            else:
                parent_fail += 1
        else:
            parent_fail += 1

        if (i + 1) % 50 == 0:
            print(f"  Progress: {i+1}/{len(parents)} (OK:{parent_success} Fail:{parent_fail})")

        # Rate limiting
        time.sleep(0.2)

    print(f"  Parents done: OK={parent_success}, Fail={parent_fail}")

    # Step 5: Verify
    print("\nStep 5: Verification...")
    ok, data = run_sql("""
        SELECT
            (SELECT COUNT(*) FROM auth.users) as auth_count,
            (SELECT COUNT(*) FROM public.users WHERE auth_uid IS NOT NULL) as linked_count,
            (SELECT COUNT(*) FROM public.users WHERE auth_uid IS NULL AND phone IS NOT NULL) as unlinked_count;
    """, "verify counts")
    if data:
        print(f"  Auth users: {data[0]['auth_count']}")
        print(f"  Linked public users: {data[0]['linked_count']}")
        print(f"  Unlinked public users: {data[0]['unlinked_count']}")

    # Test login for each role
    print("\nStep 6: Testing login for each role...")
    test_accounts = [
        ("7000000001@balvikas.pilot", "AWW"),
        ("8000000001@balvikas.pilot", "Supervisor"),
        ("8010000001@balvikas.pilot", "CDPO"),
        ("8020000001@balvikas.pilot", "DW"),
        ("8030000001@balvikas.pilot", "Senior Official"),
    ]

    for email, role in test_accounts:
        resp = requests.post(
            f"{SUPABASE_URL}/auth/v1/token?grant_type=password",
            headers={"apikey": ANON_KEY, "Content-Type": "application/json"},
            json={"email": email, "password": PASSWORD},
        )
        status = "OK" if resp.status_code == 200 else f"FAIL ({resp.status_code})"
        print(f"  {role} ({email}): {status}")
        time.sleep(0.3)

    print("\nDone!")


if __name__ == "__main__":
    main()
