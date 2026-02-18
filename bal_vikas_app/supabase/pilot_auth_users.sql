-- ============================================================
-- Pilot Auth Users: Create Supabase auth users for all mock users
-- Uses email/password auth (no Twilio needed)
-- Email pattern: {phone}@balvikas.pilot
-- Password: pilot123456
-- ============================================================
-- Run this AFTER schema.sql and mock_data.sql
-- Make sure Email auth is enabled in Supabase Dashboard
-- (Authentication → Providers → Email → Enabled)
-- ============================================================

-- Ensure required extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  user_record RECORD;
  new_auth_id UUID;
  hashed_pw TEXT;
  user_email TEXT;
BEGIN
  -- Hash the pilot password once
  hashed_pw := crypt('pilot123456', gen_salt('bf'));

  -- Loop through all users in our users table that don't have an auth_uid yet
  FOR user_record IN
    SELECT id, phone FROM public.users WHERE auth_uid IS NULL AND phone IS NOT NULL
  LOOP
    new_auth_id := gen_random_uuid();
    user_email := user_record.phone || '@balvikas.pilot';

    -- Create the auth user
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      created_at,
      updated_at,
      raw_app_meta_data,
      raw_user_meta_data,
      is_super_admin,
      confirmation_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      new_auth_id,
      'authenticated',
      'authenticated',
      user_email,
      hashed_pw,
      now(),
      now(),
      now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{}'::jsonb,
      false,
      ''
    );

    -- Create the identity record (required for email sign-in)
    INSERT INTO auth.identities (
      id,
      user_id,
      identity_data,
      provider,
      provider_id,
      last_sign_in_at,
      created_at,
      updated_at
    ) VALUES (
      new_auth_id,          -- uuid, not text
      new_auth_id,
      jsonb_build_object(
        'sub', new_auth_id::text,
        'email', user_email,
        'email_verified', true,
        'phone_verified', false
      ),
      'email',
      new_auth_id::text,    -- provider_id is text
      now(),
      now(),
      now()
    );

    -- Link auth user to our users table
    UPDATE public.users
    SET auth_uid = new_auth_id
    WHERE id = user_record.id;

    RAISE NOTICE 'Created auth user for phone: % (auth_id: %)', user_record.phone, new_auth_id;
  END LOOP;
END $$;

-- ============================================================
-- RPC function: Check if a phone number exists (callable before login)
-- Uses SECURITY DEFINER to bypass RLS for anonymous callers
-- ============================================================

CREATE OR REPLACE FUNCTION check_phone_exists(phone_number TEXT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS(SELECT 1 FROM public.users WHERE phone = phone_number AND is_active = true);
$$ LANGUAGE sql SECURITY DEFINER;

-- Grant anon role permission to call this function
GRANT EXECUTE ON FUNCTION check_phone_exists(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION check_phone_exists(TEXT) TO authenticated;

-- ============================================================
-- Verify: count auth users created
SELECT
  COUNT(*) AS total_auth_users,
  COUNT(u.auth_uid) AS linked_users
FROM public.users u;

-- Show a few sample mappings
SELECT
  u.phone,
  u.name,
  u.role,
  u.auth_uid,
  au.email
FROM public.users u
LEFT JOIN auth.users au ON au.id = u.auth_uid
ORDER BY u.role, u.phone
LIMIT 20;
