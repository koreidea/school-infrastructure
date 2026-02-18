-- ============================================================
-- Fix: RPC functions needed for pilot auth flow
-- The RLS policies prevent direct table access before auth_uid is linked.
-- These SECURITY DEFINER functions bypass RLS safely.
-- Run this in Supabase SQL Editor.
-- ============================================================

-- 1) Link the current auth user's UID to the users table by phone number
CREATE OR REPLACE FUNCTION link_auth_uid(phone_number TEXT)
RETURNS JSON AS $$
DECLARE
  updated_row public.users%ROWTYPE;
BEGIN
  UPDATE public.users
  SET auth_uid = auth.uid()
  WHERE phone = phone_number
    AND (auth_uid IS NULL OR auth_uid = auth.uid())
  RETURNING * INTO updated_row;

  IF updated_row.id IS NULL THEN
    RETURN json_build_object('error', 'No user found with phone: ' || phone_number);
  END IF;

  RETURN row_to_json(updated_row);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION link_auth_uid(TEXT) TO authenticated;

-- 2) Get the current authenticated user's profile from the users table
CREATE OR REPLACE FUNCTION get_my_profile()
RETURNS JSON AS $$
DECLARE
  profile_row public.users%ROWTYPE;
BEGIN
  SELECT * INTO profile_row
  FROM public.users
  WHERE auth_uid = auth.uid()
  LIMIT 1;

  IF profile_row.id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN row_to_json(profile_row);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_my_profile() TO authenticated;

-- Verify they were created
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('link_auth_uid', 'get_my_profile', 'check_phone_exists');
