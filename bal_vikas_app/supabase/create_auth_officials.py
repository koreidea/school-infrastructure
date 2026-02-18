#!/usr/bin/env python3
"""
Create/link GoTrue auth accounts for key officials only.
Creates 3 per role (AWW, SUPERVISOR, CDPO, DW) + 1 Senior Official.
Skips parents (they don't need login for demo).
"""

import requests
import time

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


def create_auth_and_link(phone, user_uuid):
    """Create GoTrue auth user and link to public.users."""
    email = f"{phone}@balvikas.pilot"

    # Try signup
    resp = requests.post(
        f"{SUPABASE_URL}/auth/v1/signup",
        headers={"apikey": ANON_KEY, "Content-Type": "application/json"},
        json={"email": email, "password": PASSWORD},
    )

    if resp.status_code == 200:
        new_uid = resp.json()["user"]["id"]
        ok, _ = run_sql(
            f"UPDATE public.users SET auth_uid = '{new_uid}' WHERE id = '{user_uuid}';",
            f"link {phone}"
        )
        return "CREATED" if ok else "CREATE_FAIL"
    elif resp.status_code == 429:
        # Rate limited, wait and retry
        print(f"    Rate limited for {phone}, waiting 10s...")
        time.sleep(10)
        resp2 = requests.post(
            f"{SUPABASE_URL}/auth/v1/signup",
            headers={"apikey": ANON_KEY, "Content-Type": "application/json"},
            json={"email": email, "password": PASSWORD},
        )
        if resp2.status_code == 200:
            new_uid = resp2.json()["user"]["id"]
            ok, _ = run_sql(
                f"UPDATE public.users SET auth_uid = '{new_uid}' WHERE id = '{user_uuid}';",
                f"link {phone} retry"
            )
            return "CREATED_RETRY" if ok else "RETRY_FAIL"
        return "RATE_LIMITED"
    elif resp.status_code == 422 and "already registered" in resp.text.lower():
        # Already exists in auth, just link
        ok, au_data = run_sql(
            f"SELECT id FROM auth.users WHERE email = '{email}';",
            f"find {phone}"
        )
        if au_data and len(au_data) > 0:
            existing_uid = au_data[0]['id']
            run_sql(
                f"UPDATE public.users SET auth_uid = '{existing_uid}' WHERE id = '{user_uuid}';",
                f"link existing {phone}"
            )
            return "LINKED_EXISTING"
        return "LINK_FAIL"
    else:
        print(f"    Signup failed for {email}: {resp.status_code} {resp.text[:200]}")
        return "FAIL"


def main():
    # Step 1: Link any existing auth users by email pattern matching
    print("Step 1: Linking existing auth users by email pattern...")
    ok, data = run_sql("""
        UPDATE public.users pu
        SET auth_uid = au.id
        FROM auth.users au
        WHERE au.email = pu.phone || '@balvikas.pilot'
          AND pu.auth_uid IS NULL
          AND pu.phone IS NOT NULL
        RETURNING pu.phone, pu.role;
    """, "link by email")

    if data:
        roles = {}
        for row in data:
            r = row['role']
            roles[r] = roles.get(r, 0) + 1
        print(f"  Linked {len(data)} users: {roles}")
    else:
        print("  No existing auth users to link")

    time.sleep(0.5)

    # Step 2: Check current state (officials only)
    print("\nStep 2: Current state (officials)...")
    ok, data = run_sql("""
        SELECT role, COUNT(*) as total, COUNT(auth_uid) as linked,
               COUNT(*) - COUNT(auth_uid) as unlinked
        FROM public.users
        WHERE role IN ('AWW', 'SUPERVISOR', 'CDPO', 'DW', 'SENIOR_OFFICIAL')
        GROUP BY role ORDER BY role;
    """, "check state")

    if data:
        for row in data:
            print(f"  {row['role']}: {row['total']} total, {row['linked']} linked, {row['unlinked']} unlinked")

    time.sleep(0.5)

    # Step 3: Get unlinked officials (3 per role + 1 senior)
    # We want the first 3 of each role that don't have auth yet
    print("\nStep 3: Creating auth for unlinked key officials...")

    for role, limit in [('AWW', 3), ('SUPERVISOR', 3), ('CDPO', 3), ('DW', 3), ('SENIOR_OFFICIAL', 1)]:
        ok, unlinked = run_sql(f"""
            SELECT id::text, phone
            FROM public.users
            WHERE role = '{role}' AND auth_uid IS NULL AND phone IS NOT NULL
            ORDER BY phone
            LIMIT {limit};
        """, f"get unlinked {role}")

        if not unlinked:
            print(f"  {role}: all linked already")
            continue

        print(f"  {role}: creating {len(unlinked)} auth users...")
        for user in unlinked:
            result = create_auth_and_link(user['phone'], user['id'])
            print(f"    {user['phone']}: {result}")
            time.sleep(1.5)  # Rate limit safety

    # Step 4: Final verification
    print("\nStep 4: Final state...")
    ok, data = run_sql("""
        SELECT role, COUNT(*) as total, COUNT(auth_uid) as linked
        FROM public.users
        WHERE role IN ('AWW', 'SUPERVISOR', 'CDPO', 'DW', 'SENIOR_OFFICIAL')
        GROUP BY role ORDER BY role;
    """, "final state")

    if data:
        for row in data:
            print(f"  {row['role']}: {row['linked']}/{row['total']} linked")

    # Step 5: Test login for key accounts
    print("\nStep 5: Testing logins...")
    test_accounts = [
        ("7000000001", "AWW #1"),
        ("7000000002", "AWW #2"),
        ("7000000003", "AWW #3"),
        ("8000000001", "Supervisor #1"),
        ("8000000002", "Supervisor #2"),
        ("8000000003", "Supervisor #3"),
        ("8010000001", "CDPO #1"),
        ("8010000002", "CDPO #2"),
        ("8010000003", "CDPO #3"),
        ("8020000001", "DW #1"),
        ("8020000002", "DW #2"),
        ("8020000003", "DW #3"),
        ("8030000001", "Senior Official"),
    ]

    for phone, label in test_accounts:
        email = f"{phone}@balvikas.pilot"
        resp = requests.post(
            f"{SUPABASE_URL}/auth/v1/token?grant_type=password",
            headers={"apikey": ANON_KEY, "Content-Type": "application/json"},
            json={"email": email, "password": PASSWORD},
        )
        status = "OK" if resp.status_code == 200 else f"FAIL ({resp.status_code})"
        print(f"  {label} ({phone}): {status}")
        time.sleep(0.3)

    print("\nDone!")


if __name__ == "__main__":
    main()
