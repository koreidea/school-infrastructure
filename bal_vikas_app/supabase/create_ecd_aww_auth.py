#!/usr/bin/env python3
"""
Create auth accounts for 20 ECD AWW users via GoTrue signup API.
Direct SQL INSERT into auth.users causes login errors — must use the API.

This script:
  1. Deletes broken auth entries (created by direct SQL INSERT)
  2. Nulls out auth_uid in public.users for these 20 AWWs
  3. Recreates auth via GoTrue signup API
  4. Links new auth_uid back to public.users
  5. Tests login

Prerequisites:
  Run ecd_aww_users.sql first to create the users in public.users

Usage:
  python3 create_ecd_aww_auth.py
"""

import requests
import time
import sys

SUPABASE_URL = "https://owfioycwviwjteviwkka.supabase.co"
ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93ZmlveWN3dml3anRldml3a2thIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2MzE0ODEsImV4cCI6MjA4NjIwNzQ4MX0.AyO5t28pL0N5tkukmnOdWLqINgy9_0jKXvpLCX3QYr8"
PASSWORD = "pilot123456"

# Supabase Management API for SQL
SUPABASE_TOKEN = "sbp_573715d84de517dc89b7633fdef4225c73cf238a"
PROJECT_REF = "owfioycwviwjteviwkka"
SQL_API_URL = f"https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query"
SQL_HEADERS = {
    "Authorization": f"Bearer {SUPABASE_TOKEN}",
    "Content-Type": "application/json",
}

# Top 20 AWCs by children count
AWW_PHONES = [
    "7000000392", "7000000519", "7000000319", "7000000324",
    "7000000343", "7000000344", "7000000376", "7000000404",
    "7000000409", "7000000410", "7000000411", "7000000417",
    "7000000441", "7000000457", "7000000467", "7000000530",
    "7000000552", "7000000572", "7000000625", "7000000665",
]


def run_sql(sql, label=""):
    resp = requests.post(SQL_API_URL, headers=SQL_HEADERS, json={"query": sql})
    if resp.status_code == 201:
        try:
            return True, resp.json()
        except Exception:
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
    elif "already registered" in resp.text.lower() or resp.status_code == 422:
        print(f"  {email}: already registered (skipping)")
        return "ALREADY_EXISTS"
    else:
        print(f"  Signup FAILED for {email}: {resp.status_code} {resp.text[:200]}")
        return None


def main():
    emails = [f"{phone}@balvikas.pilot" for phone in AWW_PHONES]
    email_list_sql = ", ".join(f"'{e}'" for e in emails)

    # ── Step 1: Delete broken auth entries ──
    print("Step 1: Deleting broken auth entries for 20 ECD AWWs...")

    # Delete identities first (FK constraint)
    ok, _ = run_sql(f"""
        DELETE FROM auth.identities
        WHERE user_id IN (
            SELECT id FROM auth.users WHERE email IN ({email_list_sql})
        );
    """, "delete identities")
    if ok:
        print("  Deleted identities")
    time.sleep(0.5)

    # Delete sessions
    ok, _ = run_sql(f"""
        DELETE FROM auth.sessions
        WHERE user_id IN (
            SELECT id FROM auth.users WHERE email IN ({email_list_sql})
        );
    """, "delete sessions")
    if ok:
        print("  Deleted sessions")
    time.sleep(0.5)

    # Delete refresh tokens
    ok, _ = run_sql(f"""
        DELETE FROM auth.refresh_tokens
        WHERE session_id NOT IN (SELECT id FROM auth.sessions);
    """, "delete orphan refresh tokens")
    if ok:
        print("  Deleted orphan refresh tokens")
    time.sleep(0.5)

    # Delete the broken auth.users entries
    ok, _ = run_sql(f"""
        DELETE FROM auth.users WHERE email IN ({email_list_sql});
    """, "delete broken auth users")
    if ok:
        print("  Deleted broken auth.users entries")
    time.sleep(0.5)

    # ── Step 2: Null out auth_uid in public.users ──
    print("\nStep 2: Nulling out auth_uid for 20 ECD AWWs...")
    phone_list_sql = ", ".join(f"'{p}'" for p in AWW_PHONES)
    ok, _ = run_sql(f"""
        UPDATE public.users SET auth_uid = NULL
        WHERE phone IN ({phone_list_sql});
    """, "null auth_uids")
    if ok:
        print("  Done")
    time.sleep(1)

    # ── Step 3: Recreate via GoTrue signup API ──
    print(f"\nStep 3: Creating {len(AWW_PHONES)} auth accounts via GoTrue API...")

    success = 0
    fail = 0

    for phone in AWW_PHONES:
        email = f"{phone}@balvikas.pilot"
        new_auth_uid = signup_user(email)

        if new_auth_uid and new_auth_uid != "ALREADY_EXISTS":
            # Link auth UID to public.users
            ok, _ = run_sql(
                f"UPDATE public.users SET auth_uid = '{new_auth_uid}' WHERE phone = '{phone}';",
                f"link {phone}",
            )
            if ok:
                print(f"  {phone}: OK (auth_uid={new_auth_uid[:8]}...)")
                success += 1
            else:
                fail += 1
        elif new_auth_uid == "ALREADY_EXISTS":
            # This shouldn't happen after cleanup, but handle it
            ok, data = run_sql(
                f"SELECT id FROM auth.users WHERE email = '{email}' LIMIT 1;",
                f"find existing {phone}",
            )
            if ok and data and len(data) > 0:
                existing_uid = data[0]["id"]
                run_sql(
                    f"UPDATE public.users SET auth_uid = '{existing_uid}' WHERE phone = '{phone}';",
                    f"link existing {phone}",
                )
                print(f"  {phone}: linked to existing auth user")
                success += 1
            else:
                fail += 1
        else:
            fail += 1

        time.sleep(0.3)  # Rate limiting

    print(f"\nDone: {success} created, {fail} failed")

    # ── Step 4: Verify ──
    print("\nStep 4: Verification...")
    ok, data = run_sql("""
        SELECT phone, name, awc_id, auth_uid IS NOT NULL AS has_auth
        FROM public.users
        WHERE role = 'AWW' AND awc_id >= 300
        ORDER BY awc_id;
    """, "verify")
    if ok and data:
        auth_ok = 0
        no_auth = 0
        for row in data:
            status = "AUTH OK" if row["has_auth"] else "NO AUTH"
            if row["has_auth"]:
                auth_ok += 1
            else:
                no_auth += 1
            print(f"  {row['phone']} ({row['name']}) AWC={row['awc_id']} [{status}]")
        print(f"\n  Summary: {auth_ok} with auth, {no_auth} without auth")

    # ── Step 5: Test login ──
    print("\nStep 5: Testing login...")
    test_phones = ["7000000392", "7000000519", "7000000319"]
    for phone in test_phones:
        email = f"{phone}@balvikas.pilot"
        resp = requests.post(
            f"{SUPABASE_URL}/auth/v1/token?grant_type=password",
            headers={"apikey": ANON_KEY, "Content-Type": "application/json"},
            json={"email": email, "password": PASSWORD},
        )
        if resp.status_code == 200:
            print(f"  {phone}: Login OK")
        else:
            print(f"  {phone}: Login FAILED ({resp.status_code} {resp.text[:100]})")
        time.sleep(0.3)

    print("\nAll done!")


if __name__ == "__main__":
    main()
