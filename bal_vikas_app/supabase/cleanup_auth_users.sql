-- ============================================================
-- Cleanup: Remove broken auth users created by pilot_auth_users.sql
-- Run this ONCE, then use the app's auto-signup flow instead
-- ============================================================

-- Delete identity records for pilot users
DELETE FROM auth.identities
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email LIKE '%@balvikas.pilot'
);

-- Delete auth users for pilot
DELETE FROM auth.users WHERE email LIKE '%@balvikas.pilot';

-- Clear auth_uid from our users table so the app can re-link
UPDATE public.users SET auth_uid = NULL;

-- Verify cleanup
SELECT COUNT(*) AS remaining_pilot_auth_users
FROM auth.users WHERE email LIKE '%@balvikas.pilot';

SELECT COUNT(*) AS users_with_null_auth_uid
FROM public.users WHERE auth_uid IS NULL;
