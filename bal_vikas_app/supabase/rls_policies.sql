-- ============================================================
-- Bal Vikas ECD App — Row Level Security Policies
-- Run this AFTER schema.sql and mock_data.sql
--
-- IMPORTANT: For the pilot, we use a simplified approach:
-- The app authenticates via phone OTP, then looks up the user
-- in the 'users' table. RLS policies use auth.uid() to match
-- the user's auth_uid column.
-- ============================================================

-- ============================================================
-- HELPER FUNCTION: Get the app user's role and hierarchy IDs
-- ============================================================

CREATE OR REPLACE FUNCTION get_my_user()
RETURNS TABLE(
  user_id UUID,
  role TEXT,
  awc_id INT,
  sector_id INT,
  project_id INT,
  district_id INT,
  state_id INT
) AS $$
  SELECT
    u.id,
    u.role,
    u.awc_id,
    u.sector_id,
    u.project_id,
    u.district_id,
    u.state_id
  FROM users u
  WHERE u.auth_uid = auth.uid()
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================================
-- 1. ENABLE RLS ON ALL TABLES
-- ============================================================

ALTER TABLE states ENABLE ROW LEVEL SECURITY;
ALTER TABLE districts ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE sectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE anganwadi_centres ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE children ENABLE ROW LEVEL SECURITY;
ALTER TABLE screening_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE screening_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE screening_results ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. GEOGRAPHIC TABLES — Read-only for all authenticated users
-- ============================================================

CREATE POLICY "Authenticated users can read states"
  ON states FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read districts"
  ON districts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read projects"
  ON projects FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read sectors"
  ON sectors FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read AWCs"
  ON anganwadi_centres FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================
-- 3. USERS TABLE — Users can read their own profile;
--    Staff can read users within their scope
-- ============================================================

CREATE POLICY "Users can read own profile"
  ON users FOR SELECT
  TO authenticated
  USING (auth_uid = auth.uid());

CREATE POLICY "Staff can read users in scope"
  ON users FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM get_my_user() me WHERE
        -- SENIOR_OFFICIAL: see all users in their state
        (me.role = 'SENIOR_OFFICIAL' AND (
          users.state_id = me.state_id OR
          users.district_id IN (SELECT id FROM districts WHERE state_id = me.state_id) OR
          users.project_id IN (SELECT p.id FROM projects p JOIN districts d ON p.district_id = d.id WHERE d.state_id = me.state_id) OR
          users.sector_id IN (SELECT s.id FROM sectors s JOIN projects p ON s.project_id = p.id JOIN districts d ON p.district_id = d.id WHERE d.state_id = me.state_id) OR
          users.awc_id IN (SELECT a.id FROM anganwadi_centres a JOIN sectors s ON a.sector_id = s.id JOIN projects p ON s.project_id = p.id JOIN districts d ON p.district_id = d.id WHERE d.state_id = me.state_id) OR
          users.role = 'PARENT'
        ))
        OR
        -- DW: see all users in their district
        (me.role = 'DW' AND (
          users.district_id = me.district_id OR
          users.project_id IN (SELECT id FROM projects WHERE district_id = me.district_id) OR
          users.sector_id IN (SELECT s.id FROM sectors s JOIN projects p ON s.project_id = p.id WHERE p.district_id = me.district_id) OR
          users.awc_id IN (SELECT a.id FROM anganwadi_centres a JOIN sectors s ON a.sector_id = s.id JOIN projects p ON s.project_id = p.id WHERE p.district_id = me.district_id) OR
          users.role = 'PARENT'
        ))
        OR
        -- CDPO/CW/EO: see all users in their project
        (me.role IN ('CDPO', 'CW', 'EO') AND (
          users.project_id = me.project_id OR
          users.sector_id IN (SELECT id FROM sectors WHERE project_id = me.project_id) OR
          users.awc_id IN (SELECT a.id FROM anganwadi_centres a JOIN sectors s ON a.sector_id = s.id WHERE s.project_id = me.project_id) OR
          users.role = 'PARENT'
        ))
        OR
        -- SUPERVISOR: see AWWs and parents in their sector
        (me.role = 'SUPERVISOR' AND (
          users.sector_id = me.sector_id OR
          users.awc_id IN (SELECT id FROM anganwadi_centres WHERE sector_id = me.sector_id) OR
          users.role = 'PARENT'
        ))
        OR
        -- AWW: see parents of children in their AWC
        (me.role = 'AWW' AND users.role = 'PARENT' AND users.id IN (
          SELECT parent_id FROM children WHERE awc_id = me.awc_id
        ))
    )
  );

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (auth_uid = auth.uid())
  WITH CHECK (auth_uid = auth.uid());

-- ============================================================
-- 4. CHILDREN TABLE — Role-based access
-- ============================================================

CREATE POLICY "Parents can see own children"
  ON children FOR SELECT
  TO authenticated
  USING (
    parent_id IN (SELECT user_id FROM get_my_user())
  );

CREATE POLICY "AWW can see children in their AWC"
  ON children FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role = 'AWW' AND children.awc_id = me.awc_id
    )
  );

CREATE POLICY "Supervisor can see children in their sector"
  ON children FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role = 'SUPERVISOR'
        AND children.awc_id IN (SELECT id FROM anganwadi_centres WHERE sector_id = me.sector_id)
    )
  );

CREATE POLICY "CDPO/CW/EO can see children in their project"
  ON children FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role IN ('CDPO', 'CW', 'EO')
        AND children.awc_id IN (
          SELECT a.id FROM anganwadi_centres a
          JOIN sectors s ON a.sector_id = s.id
          WHERE s.project_id = me.project_id
        )
    )
  );

CREATE POLICY "DW can see children in their district"
  ON children FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role = 'DW'
        AND children.awc_id IN (
          SELECT a.id FROM anganwadi_centres a
          JOIN sectors s ON a.sector_id = s.id
          JOIN projects p ON s.project_id = p.id
          WHERE p.district_id = me.district_id
        )
    )
  );

CREATE POLICY "Senior official can see children in their state"
  ON children FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role = 'SENIOR_OFFICIAL'
        AND children.awc_id IN (
          SELECT a.id FROM anganwadi_centres a
          JOIN sectors s ON a.sector_id = s.id
          JOIN projects p ON s.project_id = p.id
          JOIN districts d ON p.district_id = d.id
          WHERE d.state_id = me.state_id
        )
    )
  );

-- AWW can insert children in their AWC
CREATE POLICY "AWW can insert children in their AWC"
  ON children FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role = 'AWW' AND children.awc_id = me.awc_id
    )
  );

-- AWW can update children in their AWC
CREATE POLICY "AWW can update children in their AWC"
  ON children FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role = 'AWW' AND children.awc_id = me.awc_id
    )
  );

-- ============================================================
-- 5. SCREENING SESSIONS — Access follows children access
-- ============================================================

CREATE POLICY "Users can read screening sessions for accessible children"
  ON screening_sessions FOR SELECT
  TO authenticated
  USING (
    child_id IN (SELECT id FROM children)  -- RLS on children table handles filtering
  );

CREATE POLICY "AWW can insert screening sessions"
  ON screening_sessions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role IN ('AWW', 'SUPERVISOR', 'CDPO')
    )
  );

CREATE POLICY "AWW can update own screening sessions"
  ON screening_sessions FOR UPDATE
  TO authenticated
  USING (
    conducted_by IN (SELECT user_id FROM get_my_user())
  );

-- ============================================================
-- 6. SCREENING RESPONSES — Access follows sessions
-- ============================================================

CREATE POLICY "Users can read responses for accessible sessions"
  ON screening_responses FOR SELECT
  TO authenticated
  USING (
    session_id IN (SELECT id FROM screening_sessions)  -- RLS on sessions handles filtering
  );

CREATE POLICY "Staff can insert screening responses"
  ON screening_responses FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role IN ('AWW', 'SUPERVISOR', 'CDPO')
    )
  );

-- ============================================================
-- 7. SCREENING RESULTS — Access follows sessions
-- ============================================================

CREATE POLICY "Users can read results for accessible children"
  ON screening_results FOR SELECT
  TO authenticated
  USING (
    child_id IN (SELECT id FROM children)  -- RLS on children table handles filtering
  );

CREATE POLICY "Staff can insert screening results"
  ON screening_results FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM get_my_user() me
      WHERE me.role IN ('AWW', 'SUPERVISOR', 'CDPO')
    )
  );

-- ============================================================
-- 8. SERVICE ROLE BYPASS (for admin/migration operations)
-- ============================================================
-- Supabase service_role key bypasses RLS by default.
-- No additional policies needed for admin operations.

-- ============================================================
-- SUMMARY OF ACCESS RULES
-- ============================================================
--
-- PARENT:          Read own children + their screening data
-- AWW:             Read/Write children in own AWC + screening data
-- SUPERVISOR:      Read all children in sector (5 AWCs)
-- CDPO/CW/EO:      Read all children in project (all sectors)
-- DW:              Read all children in district (all projects)
-- SENIOR_OFFICIAL: Read all children in state
--
-- Geographic tables (states, districts, etc.) are readable by all.
-- Only AWW/Supervisor/CDPO can create screening data.
-- ============================================================
