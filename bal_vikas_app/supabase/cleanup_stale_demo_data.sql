-- ============================================================
-- Clean up stale demo data for App Data children (IDs 1-200)
-- The old demo_1000_data.sql inserted referrals, followups, and
-- screening data for children 1-1000. These were never cleaned up
-- when ecd_sample_import.sql was run (which only cleans 5000-5999).
-- This script removes stale demo data for App Data children.
-- ============================================================

-- Delete stale referrals for App Data children (from old demo_1000_data)
DELETE FROM referrals WHERE child_id BETWEEN 1 AND 200;

-- Delete stale intervention_followups for App Data children (from old demo_1000_data)
DELETE FROM intervention_followups WHERE child_id BETWEEN 1 AND 200;

-- Delete stale screening_results for App Data children (from old demo_1000_data)
DELETE FROM screening_results WHERE child_id BETWEEN 1 AND 200;

-- Delete stale screening_sessions for App Data children (from old demo_1000_data)
DELETE FROM screening_sessions WHERE child_id BETWEEN 1 AND 200;

-- Also clean up any remaining demo data for children 201-1000 (no longer exist)
DELETE FROM referrals WHERE child_id BETWEEN 201 AND 999;
DELETE FROM intervention_followups WHERE child_id BETWEEN 201 AND 999;
DELETE FROM screening_results WHERE child_id BETWEEN 201 AND 999;
DELETE FROM screening_sessions WHERE child_id BETWEEN 201 AND 999;
