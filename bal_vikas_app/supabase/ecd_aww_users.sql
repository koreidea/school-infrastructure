-- ============================================================
-- ECD Sample Data: Create 20 AWW users for top-20 AWCs by children count
-- Phone pattern: 700{awc_id:07d}  (e.g., AWC 392 -> 7000000392)
-- UUID pattern: 10000000-0000-0000-0001-{awc_id:012d}
-- ============================================================
-- STEP 1: Run this SQL in Supabase SQL editor to insert users
-- STEP 2: Run create_ecd_aww_auth.py to create auth accounts via GoTrue API
-- ============================================================

-- 1. Insert 20 AWW users into public.users
INSERT INTO users (id, phone, name, role, gender, awc_id, preferred_language) VALUES
  ('10000000-0000-0000-0001-000000000392', '7000000392', 'Lakshmi Devi',     'AWW', 'female', 392, 'te'),
  ('10000000-0000-0000-0001-000000000519', '7000000519', 'Padma Kumari',     'AWW', 'female', 519, 'te'),
  ('10000000-0000-0000-0001-000000000319', '7000000319', 'Sridevi Rani',     'AWW', 'female', 319, 'te'),
  ('10000000-0000-0000-0001-000000000324', '7000000324', 'Anuradha Devi',    'AWW', 'female', 324, 'te'),
  ('10000000-0000-0000-0001-000000000343', '7000000343', 'Kavitha Kumari',   'AWW', 'female', 343, 'te'),
  ('10000000-0000-0000-0001-000000000344', '7000000344', 'Sunitha Devi',     'AWW', 'female', 344, 'te'),
  ('10000000-0000-0000-0001-000000000376', '7000000376', 'Radha Kumari',     'AWW', 'female', 376, 'te'),
  ('10000000-0000-0000-0001-000000000404', '7000000404', 'Vijaya Lakshmi',   'AWW', 'female', 404, 'te'),
  ('10000000-0000-0000-0001-000000000409', '7000000409', 'Manga Devi',       'AWW', 'female', 409, 'te'),
  ('10000000-0000-0000-0001-000000000410', '7000000410', 'Durga Bhavani',    'AWW', 'female', 410, 'te'),
  ('10000000-0000-0000-0001-000000000411', '7000000411', 'Saraswathi Kumari','AWW', 'female', 411, 'te'),
  ('10000000-0000-0000-0001-000000000417', '7000000417', 'Bhavani Devi',     'AWW', 'female', 417, 'te'),
  ('10000000-0000-0000-0001-000000000441', '7000000441', 'Anitha Rani',      'AWW', 'female', 441, 'te'),
  ('10000000-0000-0000-0001-000000000457', '7000000457', 'Padmaja Devi',     'AWW', 'female', 457, 'te'),
  ('10000000-0000-0000-0001-000000000467', '7000000467', 'Meenakshi Devi',   'AWW', 'female', 467, 'te'),
  ('10000000-0000-0000-0001-000000000530', '7000000530', 'Jayashree Kumari', 'AWW', 'female', 530, 'te'),
  ('10000000-0000-0000-0001-000000000552', '7000000552', 'Sumithra Devi',    'AWW', 'female', 552, 'te'),
  ('10000000-0000-0000-0001-000000000572', '7000000572', 'Kamala Kumari',    'AWW', 'female', 572, 'te'),
  ('10000000-0000-0000-0001-000000000625', '7000000625', 'Renuka Devi',      'AWW', 'female', 625, 'te'),
  ('10000000-0000-0000-0001-000000000665', '7000000665', 'Parvathi Kumari',  'AWW', 'female', 665, 'te')
ON CONFLICT (id) DO UPDATE SET
  phone = EXCLUDED.phone,
  name = EXCLUDED.name,
  awc_id = EXCLUDED.awc_id;

-- 2. Create the get_children_for_awc_full RPC (AWC-level children fetch)
CREATE OR REPLACE FUNCTION get_children_for_awc_full(p_awc_id INT)
RETURNS TABLE(
  id INT,
  child_unique_id TEXT,
  name TEXT,
  dob TEXT,
  gender TEXT,
  awc_id INT,
  photo_url TEXT,
  parent_id UUID,
  aww_id UUID,
  is_active BOOLEAN
) AS $$
  SELECT c.id, c.child_unique_id, c.name, c.dob::TEXT, c.gender, c.awc_id,
         c.photo_url, c.parent_id, c.aww_id, c.is_active
  FROM children c
  WHERE c.awc_id = p_awc_id
    AND c.is_active = true
  ORDER BY c.name;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 3. Verify users were created (auth accounts created separately via Python script)
SELECT u.phone, u.name, u.awc_id, u.auth_uid IS NOT NULL AS has_auth,
       (SELECT COUNT(*) FROM children c WHERE c.awc_id = u.awc_id AND c.is_active = true) AS children_count
FROM users u
WHERE u.role = 'AWW' AND u.awc_id >= 300
ORDER BY children_count DESC;
