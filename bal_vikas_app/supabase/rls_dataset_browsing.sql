-- ============================================================
-- RPC functions for cross-project dataset browsing
-- These use SECURITY DEFINER to bypass RLS, allowing users
-- to browse ECD Sample data even if their role is scoped to
-- a different project/district.
-- ============================================================

-- Drop functions whose return types have changed
DROP FUNCTION IF EXISTS get_screening_results_for_children(INT[]);
DROP FUNCTION IF EXISTS get_followups_for_children(INT[]);

-- 1. Get child IDs for a given project (via hierarchy traversal)
CREATE OR REPLACE FUNCTION get_children_for_project(p_project_id INT)
RETURNS TABLE(child_id INT) AS $$
  SELECT c.id AS child_id
  FROM children c
  JOIN anganwadi_centres a ON c.awc_id = a.id
  JOIN sectors s ON a.sector_id = s.id
  WHERE s.project_id = p_project_id
    AND c.is_active = true
    AND a.is_active = true;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 2. Get child IDs for a given district
CREATE OR REPLACE FUNCTION get_children_for_district(p_district_id INT)
RETURNS TABLE(child_id INT) AS $$
  SELECT c.id AS child_id
  FROM children c
  JOIN anganwadi_centres a ON c.awc_id = a.id
  JOIN sectors s ON a.sector_id = s.id
  JOIN projects p ON s.project_id = p.id
  WHERE p.district_id = p_district_id
    AND c.is_active = true
    AND a.is_active = true;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 3. Get screening results for a list of child IDs (bypasses RLS)
--    Returns all columns needed by dashboard + reports + model validation tabs
CREATE OR REPLACE FUNCTION get_screening_results_for_children(p_child_ids INT[])
RETURNS TABLE(
  id INT,
  child_id INT,
  session_id INT,
  overall_risk TEXT,
  baseline_category TEXT,
  referral_needed BOOLEAN,
  gm_dq DOUBLE PRECISION,
  fm_dq DOUBLE PRECISION,
  lc_dq DOUBLE PRECISION,
  cog_dq DOUBLE PRECISION,
  se_dq DOUBLE PRECISION,
  composite_dq DOUBLE PRECISION,
  num_delays INT,
  assessment_cycle TEXT,
  autism_risk TEXT,
  adhd_risk TEXT,
  behavior_risk TEXT,
  behavior_score INT,
  baseline_score INT,
  tools_completed INT,
  tools_skipped INT,
  tool_results JSONB,
  created_at TIMESTAMPTZ
) AS $$
  SELECT sr.id, sr.child_id, sr.session_id, sr.overall_risk, sr.baseline_category,
         sr.referral_needed, sr.gm_dq, sr.fm_dq, sr.lc_dq, sr.cog_dq, sr.se_dq,
         sr.composite_dq,
         COALESCE(sr.num_delays, 0)::INT AS num_delays,
         sr.assessment_cycle,
         sr.autism_risk, sr.adhd_risk, sr.behavior_risk,
         COALESCE(sr.behavior_score, 0)::INT AS behavior_score,
         COALESCE(sr.baseline_score, 0)::INT AS baseline_score,
         COALESCE(sr.tools_completed, 0)::INT AS tools_completed,
         COALESCE(sr.tools_skipped, 0)::INT AS tools_skipped,
         sr.tool_results, sr.created_at
  FROM screening_results sr
  WHERE sr.child_id = ANY(p_child_ids)
  ORDER BY sr.created_at DESC;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 4. Get referrals for a list of child IDs (bypasses RLS)
CREATE OR REPLACE FUNCTION get_referrals_for_children(p_child_ids INT[])
RETURNS TABLE(
  child_id INT,
  referral_status TEXT
) AS $$
  SELECT r.child_id, r.referral_status
  FROM referrals r
  WHERE r.child_id = ANY(p_child_ids);
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 5. Get intervention followups for a list of child IDs (bypasses RLS)
CREATE OR REPLACE FUNCTION get_followups_for_children(p_child_ids INT[])
RETURNS TABLE(
  child_id INT,
  improvement_status TEXT,
  domain_improvement BOOLEAN,
  exit_high_risk BOOLEAN
) AS $$
  SELECT f.child_id, f.improvement_status, f.domain_improvement, f.exit_high_risk
  FROM intervention_followups f
  WHERE f.child_id = ANY(p_child_ids);
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 6. Get FULL child records for a project (for children list screen)
CREATE OR REPLACE FUNCTION get_children_for_project_full(p_project_id INT)
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
  JOIN anganwadi_centres a ON c.awc_id = a.id
  JOIN sectors s ON a.sector_id = s.id
  WHERE s.project_id = p_project_id
    AND c.is_active = true
    AND a.is_active = true
  ORDER BY c.name;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 6b. Get FULL child records for a single AWC (for AWW dashboard with dataset override)
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

-- 7. Get a single child by ID (bypasses RLS, for child detail screen)
CREATE OR REPLACE FUNCTION get_child_by_id(p_child_id INT)
RETURNS TABLE(
  id INT,
  child_unique_id TEXT,
  name TEXT,
  dob TEXT,
  gender TEXT,
  awc_id INT,
  photo_url TEXT,
  parent_id UUID,
  aww_id UUID
) AS $$
  SELECT c.id, c.child_unique_id, c.name, c.dob::TEXT, c.gender, c.awc_id,
         c.photo_url, c.parent_id, c.aww_id
  FROM children c
  WHERE c.id = p_child_id;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 8. Get children for a scope (bypasses RLS, for scoped list screens)
CREATE OR REPLACE FUNCTION get_children_for_scope(p_scope TEXT, p_scope_id INT)
RETURNS TABLE(
  id INT,
  child_unique_id TEXT,
  name TEXT,
  dob TEXT,
  gender TEXT,
  awc_id INT,
  photo_url TEXT,
  parent_id UUID,
  aww_id UUID
) AS $$
  SELECT c.id, c.child_unique_id, c.name, c.dob::TEXT, c.gender, c.awc_id,
         c.photo_url, c.parent_id, c.aww_id
  FROM children c
  JOIN anganwadi_centres a ON c.awc_id = a.id
  JOIN sectors s ON a.sector_id = s.id
  JOIN projects p ON s.project_id = p.id
  WHERE c.is_active = true
    AND a.is_active = true
    AND (
      (p_scope = 'awc' AND c.awc_id = p_scope_id) OR
      (p_scope = 'sector' AND a.sector_id = p_scope_id) OR
      (p_scope = 'project' AND s.project_id = p_scope_id) OR
      (p_scope = 'district' AND p.district_id = p_scope_id) OR
      (p_scope = 'state' AND p.district_id IN (SELECT d.id FROM districts d WHERE d.state_id = p_scope_id))
    )
  ORDER BY c.name;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 9. Get FULL referral records for children (for reports tab)
CREATE OR REPLACE FUNCTION get_full_referrals_for_children(p_child_ids INT[])
RETURNS TABLE(
  id INT,
  child_id INT,
  referral_status TEXT,
  referral_type TEXT,
  referral_reason TEXT,
  referred_date TEXT,
  completed_date TEXT,
  created_at TIMESTAMPTZ
) AS $$
  SELECT r.id, r.child_id, r.referral_status, r.referral_type, r.referral_reason,
         r.referred_date::TEXT, r.completed_date::TEXT, r.created_at
  FROM referrals r
  WHERE r.child_id = ANY(p_child_ids)
  ORDER BY r.created_at DESC;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 10. Get FULL intervention followup records for children (for reports tab)
CREATE OR REPLACE FUNCTION get_full_followups_for_children(p_child_ids INT[])
RETURNS TABLE(
  child_id INT,
  improvement_status TEXT,
  domain_improvement BOOLEAN,
  exit_high_risk BOOLEAN,
  followup_conducted BOOLEAN,
  reduction_in_delay_months INT,
  intervention_plan_generated BOOLEAN,
  home_activities_assigned INT
) AS $$
  SELECT f.child_id, f.improvement_status, f.domain_improvement, f.exit_high_risk,
         f.followup_conducted,
         COALESCE(f.reduction_in_delay_months, 0)::INT,
         f.intervention_plan_generated,
         COALESCE(f.home_activities_assigned, 0)::INT
  FROM intervention_followups f
  WHERE f.child_id = ANY(p_child_ids);
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 11. Generic table query for children (bypasses RLS)
--     Supports: children, nutrition_assessments, environment_assessments
CREATE OR REPLACE FUNCTION get_table_for_children(p_table_name TEXT, p_child_ids INT[])
RETURNS SETOF JSONB AS $$
BEGIN
  IF p_table_name = 'children' THEN
    RETURN QUERY
      SELECT to_jsonb(c.*) FROM children c WHERE c.id = ANY(p_child_ids);
  ELSIF p_table_name = 'nutrition_assessments' THEN
    RETURN QUERY
      SELECT to_jsonb(n.*) FROM nutrition_assessments n WHERE n.child_id = ANY(p_child_ids);
  ELSIF p_table_name = 'environment_assessments' THEN
    RETURN QUERY
      SELECT to_jsonb(e.*) FROM environment_assessments e WHERE e.child_id = ANY(p_child_ids);
  ELSE
    RAISE EXCEPTION 'Unsupported table: %', p_table_name;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- 12. Get screening history for a single child (results + session info, bypasses RLS)
CREATE OR REPLACE FUNCTION get_screening_history_for_child(p_child_id INT)
RETURNS TABLE(
  id INT,
  child_id INT,
  session_id INT,
  overall_risk TEXT,
  composite_dq DOUBLE PRECISION,
  gm_dq DOUBLE PRECISION,
  fm_dq DOUBLE PRECISION,
  lc_dq DOUBLE PRECISION,
  cog_dq DOUBLE PRECISION,
  se_dq DOUBLE PRECISION,
  referral_needed BOOLEAN,
  tools_completed TEXT,
  tools_skipped TEXT,
  created_at TIMESTAMPTZ,
  assessment_date TEXT,
  child_age_months INT,
  session_status TEXT
) AS $$
  SELECT sr.id, sr.child_id, sr.session_id, sr.overall_risk,
         sr.composite_dq, sr.gm_dq, sr.fm_dq, sr.lc_dq, sr.cog_dq, sr.se_dq,
         sr.referral_needed, sr.tools_completed, sr.tools_skipped, sr.created_at,
         ss.assessment_date::TEXT, ss.child_age_months, ss.status
  FROM screening_results sr
  JOIN screening_sessions ss ON sr.session_id = ss.id
  WHERE sr.child_id = p_child_id
  ORDER BY sr.created_at DESC;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 13. Get hierarchy items for any level (bypasses RLS for cross-project browsing)
--     Supports: districts, projects, sectors, awcs
CREATE OR REPLACE FUNCTION get_hierarchy_items(p_level TEXT, p_scope_id INT)
RETURNS SETOF JSONB AS $$
BEGIN
  IF p_level = 'districts' THEN
    RETURN QUERY SELECT to_jsonb(d.*) FROM districts d WHERE d.state_id = p_scope_id ORDER BY d.name;
  ELSIF p_level = 'projects' THEN
    RETURN QUERY SELECT to_jsonb(p.*) FROM projects p WHERE p.district_id = p_scope_id ORDER BY p.name;
  ELSIF p_level = 'sectors' THEN
    RETURN QUERY SELECT to_jsonb(s.*) FROM sectors s WHERE s.project_id = p_scope_id ORDER BY s.name;
  ELSIF p_level = 'awcs' THEN
    RETURN QUERY SELECT to_jsonb(a.*) FROM anganwadi_centres a WHERE a.sector_id = p_scope_id AND a.is_active = true ORDER BY a.centre_code;
  ELSE
    RAISE EXCEPTION 'Unsupported level: %', p_level;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

