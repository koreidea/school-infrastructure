#!/usr/bin/env python3
"""
Fix auth user linking after GoTrue API signup.
1. Link officials (AWW, Supervisor, CDPO, DW, Senior) by matching email pattern
2. Create parent auth users with proper rate limiting
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
        print(f"  SQL ERROR ({label}): {resp.text[:400]}")
        return False, None


def main():
    # Step 1: Link officials via SQL matching (email pattern -> phone -> public.users)
    print("Step 1: Linking officials via email pattern matching...")
    ok, data = run_sql("""
        UPDATE public.users pu
        SET auth_uid = au.id
        FROM auth.users au
        WHERE au.email = pu.phone || '@balvikas.pilot'
          AND pu.auth_uid IS NULL
          AND pu.phone IS NOT NULL
        RETURNING pu.phone, pu.role, au.id as new_auth_uid;
    """, "link officials by email")

    if data:
        print(f"  Linked {len(data)} users")
        # Show count per role
        roles = {}
        for row in data:
            r = row['role']
            roles[r] = roles.get(r, 0) + 1
        for r, c in sorted(roles.items()):
            print(f"    {r}: {c}")
    else:
        print("  No users to link (or all already linked)")

    time.sleep(0.5)

    # Step 2: Check current state
    print("\nStep 2: Current state...")
    ok, data = run_sql("""
        SELECT
            role,
            COUNT(*) as total,
            COUNT(auth_uid) as linked,
            COUNT(*) - COUNT(auth_uid) as unlinked
        FROM public.users
        WHERE phone IS NOT NULL
        GROUP BY role
        ORDER BY role;
    """, "check state")

    if data:
        for row in data:
            print(f"  {row['role']}: {row['total']} total, {row['linked']} linked, {row['unlinked']} unlinked")

    time.sleep(0.5)

    # Step 3: Create parent auth users with proper rate limiting
    # Check how many parents still need auth
    ok, parents = run_sql("""
        SELECT id::text, phone
        FROM public.users
        WHERE role = 'PARENT' AND auth_uid IS NULL AND phone IS NOT NULL
        ORDER BY phone
        LIMIT 1000;
    """, "get unlinked parents")

    if not parents:
        print("\nAll parents already have auth! Done.")
        return

    print(f"\nStep 3: Creating {len(parents)} parent auth users (with rate limiting)...")
    print("  This will take ~17 minutes at 1 req/sec...")

    success = 0
    fail = 0
    rate_limited = 0

    for i, parent in enumerate(parents):
        phone = parent['phone']
        user_uuid = parent['id']
        email = f"{phone}@balvikas.pilot"

        # Signup via GoTrue API
        resp = requests.post(
            f"{SUPABASE_URL}/auth/v1/signup",
            headers={"apikey": ANON_KEY, "Content-Type": "application/json"},
            json={"email": email, "password": PASSWORD},
        )

        if resp.status_code == 200:
            new_uid = resp.json()["user"]["id"]
            # Link with proper UUID quoting
            ok, _ = run_sql(f"""
                UPDATE public.users SET auth_uid = '{new_uid}' WHERE id = '{user_uuid}';
            """, f"link {phone}")
            if ok:
                success += 1
            else:
                fail += 1
        elif resp.status_code == 429:
            rate_limited += 1
            # Wait longer on rate limit
            wait_time = 5
            if rate_limited > 5:
                wait_time = 10
            if rate_limited > 10:
                wait_time = 30
            if (i + 1) % 10 == 0 or rate_limited <= 3:
                print(f"  Rate limited at {i+1}/{len(parents)}, waiting {wait_time}s...")
            time.sleep(wait_time)
            # Retry
            resp2 = requests.post(
                f"{SUPABASE_URL}/auth/v1/signup",
                headers={"apikey": ANON_KEY, "Content-Type": "application/json"},
                json={"email": email, "password": PASSWORD},
            )
            if resp2.status_code == 200:
                new_uid = resp2.json()["user"]["id"]
                ok, _ = run_sql(f"""
                    UPDATE public.users SET auth_uid = '{new_uid}' WHERE id = '{user_uuid}';
                """, f"link {phone} (retry)")
                if ok:
                    success += 1
                    rate_limited = max(0, rate_limited - 1)
                else:
                    fail += 1
            else:
                fail += 1
        elif resp.status_code == 422 and "already registered" in resp.text.lower():
            # Already exists, just link
            ok, au_data = run_sql(f"""
                SELECT id FROM auth.users WHERE email = '{email}';
            """, f"find existing {phone}")
            if au_data and len(au_data) > 0:
                existing_uid = au_data[0]['id']
                run_sql(f"""
                    UPDATE public.users SET auth_uid = '{existing_uid}' WHERE id = '{user_uuid}';
                """, f"link existing {phone}")
                success += 1
            else:
                fail += 1
        else:
            fail += 1
            if fail <= 5:
                print(f"  Signup FAILED for {email}: {resp.status_code} {resp.text[:200]}")

        if (i + 1) % 100 == 0:
            print(f"  Progress: {i+1}/{len(parents)} (OK:{success} Fail:{fail})")

        # Rate limit: ~1 request per second
        time.sleep(1.0)

    print(f"\n  Parents done: OK={success}, Fail={fail}")

    # Step 4: Final verification
    print("\nStep 4: Final verification...")
    ok, data = run_sql("""
        SELECT
            (SELECT COUNT(*) FROM auth.users) as auth_count,
            (SELECT COUNT(*) FROM public.users WHERE auth_uid IS NOT NULL) as linked_count,
            (SELECT COUNT(*) FROM public.users WHERE auth_uid IS NULL AND phone IS NOT NULL) as unlinked_count;
    """, "final counts")
    if data:
        print(f"  Auth users: {data[0]['auth_count']}")
        print(f"  Linked: {data[0]['linked_count']}")
        print(f"  Unlinked: {data[0]['unlinked_count']}")

    # Test login
    print("\nStep 5: Testing login for each role...")
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
