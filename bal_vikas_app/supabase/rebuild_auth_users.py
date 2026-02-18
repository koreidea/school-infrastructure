#!/usr/bin/env python3
"""
Clean up old auth users and create new ones for all users without auth_uid.
"""

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
        print(f"  OK - {label}")
        return True
    else:
        print(f"  ERROR ({resp.status_code}) - {label}: {resp.text[:500]}")
        return False


# Step 1: Clean up orphaned auth users (whose email ends with @balvikas.pilot
# but have no matching users record)
print("Step 1: Cleaning up old auth users...")
execute_sql("""
DELETE FROM auth.identities
WHERE user_id IN (
    SELECT au.id FROM auth.users au
    WHERE au.email LIKE '%@balvikas.pilot'
    AND NOT EXISTS (SELECT 1 FROM public.users u WHERE u.auth_uid = au.id)
);
""", "Delete orphaned identities")
time.sleep(0.5)

execute_sql("""
DELETE FROM auth.users
WHERE email LIKE '%@balvikas.pilot'
AND NOT EXISTS (SELECT 1 FROM public.users u WHERE u.auth_uid = auth.users.id);
""", "Delete orphaned auth users")
time.sleep(0.5)

# Step 2: Create auth users for officials (non-PARENT, non-AWW first as they're fewer)
print("\nStep 2: Creating auth users for all users...")
execute_sql("""
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  user_record RECORD;
  new_auth_id UUID;
  hashed_pw TEXT;
  user_email TEXT;
  cnt INT := 0;
BEGIN
  hashed_pw := crypt('pilot123456', gen_salt('bf'));

  FOR user_record IN
    SELECT id, phone FROM public.users
    WHERE auth_uid IS NULL AND phone IS NOT NULL
    AND role IN ('SENIOR_OFFICIAL', 'DW', 'CDPO', 'CW', 'EO', 'SUPERVISOR', 'AWW')
  LOOP
    new_auth_id := gen_random_uuid();
    user_email := user_record.phone || '@balvikas.pilot';

    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, confirmation_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', new_auth_id,
      'authenticated', 'authenticated', user_email, hashed_pw,
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{}'::jsonb, false, ''
    );

    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, provider_id,
      last_sign_in_at, created_at, updated_at
    ) VALUES (
      new_auth_id, new_auth_id,
      jsonb_build_object('sub', new_auth_id::text, 'email', user_email,
                         'email_verified', true, 'phone_verified', false),
      'email', new_auth_id::text, now(), now(), now()
    );

    UPDATE public.users SET auth_uid = new_auth_id WHERE id = user_record.id;
    cnt := cnt + 1;
  END LOOP;

  RAISE NOTICE 'Created % auth users for officials + AWWs', cnt;
END $$;
""", "Create auth for officials + AWWs")
time.sleep(1)

# Step 3: Create auth users for PARENTS in batches (there are ~976)
# Do it in chunks to avoid timeout
print("\nStep 3: Creating auth users for parents (batched)...")

for batch_num in range(20):  # 20 batches of ~50 each
    ok = execute_sql(f"""
DO $$
DECLARE
  user_record RECORD;
  new_auth_id UUID;
  hashed_pw TEXT;
  user_email TEXT;
  cnt INT := 0;
BEGIN
  hashed_pw := crypt('pilot123456', gen_salt('bf'));

  FOR user_record IN
    SELECT id, phone FROM public.users
    WHERE auth_uid IS NULL AND phone IS NOT NULL AND role = 'PARENT'
    ORDER BY phone
    LIMIT 50
  LOOP
    new_auth_id := gen_random_uuid();
    user_email := user_record.phone || '@balvikas.pilot';

    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, confirmation_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', new_auth_id,
      'authenticated', 'authenticated', user_email, hashed_pw,
      now(), now(), now(),
      '{{"provider":"email","providers":["email"]}}'::jsonb,
      '{{}}'::jsonb, false, ''
    );

    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, provider_id,
      last_sign_in_at, created_at, updated_at
    ) VALUES (
      new_auth_id, new_auth_id,
      jsonb_build_object('sub', new_auth_id::text, 'email', user_email,
                         'email_verified', true, 'phone_verified', false),
      'email', new_auth_id::text, now(), now(), now()
    );

    UPDATE public.users SET auth_uid = new_auth_id WHERE id = user_record.id;
    cnt := cnt + 1;
  END LOOP;

  RAISE NOTICE 'Created % parent auth users (batch {batch_num + 1})', cnt;
END $$;
""", f"Parents batch {batch_num + 1}/20")
    time.sleep(0.5)
    if not ok:
        break

# Step 4: Verify
print("\nStep 4: Verifying...")
execute_sql("""
SELECT role, COUNT(*) as total, COUNT(auth_uid) as with_auth
FROM public.users
GROUP BY role
ORDER BY role;
""", "Count users by role")

print("\nDone! All users should now be able to log in with password: pilot123456")
