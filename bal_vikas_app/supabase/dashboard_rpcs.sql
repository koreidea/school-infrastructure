-- ============================================================
-- Dashboard aggregate stats RPC
-- Run this in Supabase SQL Editor
-- Provides aggregate statistics for CDPO, DW, and Senior Official dashboards
-- ============================================================

CREATE OR REPLACE FUNCTION get_dashboard_stats(p_scope TEXT, p_scope_id INT)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  -- ============================================================
  -- SCOPE = 'project' (for CDPO / CW / EO)
  -- ============================================================
  IF p_scope = 'project' THEN
    SELECT json_build_object(
      'scope', 'project',
      'total_sectors', (
        SELECT COUNT(*) FROM sectors WHERE project_id = p_scope_id
      ),
      'total_awcs', (
        SELECT COUNT(*) FROM anganwadi_centres ac
        JOIN sectors s ON ac.sector_id = s.id
        WHERE s.project_id = p_scope_id AND ac.is_active = true
      ),
      'total_children', (
        SELECT COUNT(*) FROM children c
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        WHERE s.project_id = p_scope_id AND c.is_active = true
      ),
      'screened_this_month', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        WHERE s.project_id = p_scope_id
          AND sr.created_at >= date_trunc('month', CURRENT_DATE)
      ),
      'high_risk_count', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        WHERE s.project_id = p_scope_id
          AND sr.overall_risk = 'HIGH'
          AND sr.id = (
            SELECT MAX(sr2.id) FROM screening_results sr2 WHERE sr2.child_id = sr.child_id
          )
      ),
      'referrals_needed', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        WHERE s.project_id = p_scope_id
          AND sr.referral_needed = true
          AND sr.id = (
            SELECT MAX(sr2.id) FROM screening_results sr2 WHERE sr2.child_id = sr.child_id
          )
      ),
      'sub_units', (
        SELECT COALESCE(json_agg(row_to_json(sub)), '[]'::json)
        FROM (
          SELECT
            s.id,
            s.name,
            (SELECT COUNT(*) FROM anganwadi_centres ac2 WHERE ac2.sector_id = s.id AND ac2.is_active = true) AS sub_unit_count,
            (SELECT COUNT(*) FROM children c2
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             WHERE ac2.sector_id = s.id AND c2.is_active = true) AS children_count,
            (SELECT COUNT(DISTINCT sr2.child_id) FROM screening_results sr2
             JOIN children c2 ON sr2.child_id = c2.id
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             WHERE ac2.sector_id = s.id
               AND sr2.created_at >= date_trunc('month', CURRENT_DATE)) AS screened_count,
            (SELECT COUNT(DISTINCT sr2.child_id) FROM screening_results sr2
             JOIN children c2 ON sr2.child_id = c2.id
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             WHERE ac2.sector_id = s.id AND sr2.overall_risk = 'HIGH'
               AND sr2.id = (SELECT MAX(sr3.id) FROM screening_results sr3 WHERE sr3.child_id = sr2.child_id)
            ) AS high_risk_count
          FROM sectors s
          WHERE s.project_id = p_scope_id
          ORDER BY s.name
        ) sub
      )
    ) INTO result;

    RETURN result;

  -- ============================================================
  -- SCOPE = 'district' (for DW)
  -- ============================================================
  ELSIF p_scope = 'district' THEN
    SELECT json_build_object(
      'scope', 'district',
      'total_projects', (
        SELECT COUNT(*) FROM projects WHERE district_id = p_scope_id
      ),
      'total_sectors', (
        SELECT COUNT(*) FROM sectors s
        JOIN projects p ON s.project_id = p.id
        WHERE p.district_id = p_scope_id
      ),
      'total_awcs', (
        SELECT COUNT(*) FROM anganwadi_centres ac
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        WHERE p.district_id = p_scope_id AND ac.is_active = true
      ),
      'total_children', (
        SELECT COUNT(*) FROM children c
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        WHERE p.district_id = p_scope_id AND c.is_active = true
      ),
      'screened_this_month', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        WHERE p.district_id = p_scope_id
          AND sr.created_at >= date_trunc('month', CURRENT_DATE)
      ),
      'high_risk_count', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        WHERE p.district_id = p_scope_id
          AND sr.overall_risk = 'HIGH'
          AND sr.id = (SELECT MAX(sr2.id) FROM screening_results sr2 WHERE sr2.child_id = sr.child_id)
      ),
      'referrals_needed', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        WHERE p.district_id = p_scope_id
          AND sr.referral_needed = true
          AND sr.id = (SELECT MAX(sr2.id) FROM screening_results sr2 WHERE sr2.child_id = sr.child_id)
      ),
      'sub_units', (
        SELECT COALESCE(json_agg(row_to_json(sub)), '[]'::json)
        FROM (
          SELECT
            p.id,
            p.name,
            (SELECT COUNT(*) FROM sectors s2 WHERE s2.project_id = p.id) AS sub_unit_count,
            (SELECT COUNT(*) FROM children c2
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             JOIN sectors s2 ON ac2.sector_id = s2.id
             WHERE s2.project_id = p.id AND c2.is_active = true) AS children_count,
            (SELECT COUNT(DISTINCT sr2.child_id) FROM screening_results sr2
             JOIN children c2 ON sr2.child_id = c2.id
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             JOIN sectors s2 ON ac2.sector_id = s2.id
             WHERE s2.project_id = p.id
               AND sr2.created_at >= date_trunc('month', CURRENT_DATE)) AS screened_count,
            (SELECT COUNT(DISTINCT sr2.child_id) FROM screening_results sr2
             JOIN children c2 ON sr2.child_id = c2.id
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             JOIN sectors s2 ON ac2.sector_id = s2.id
             WHERE s2.project_id = p.id AND sr2.overall_risk = 'HIGH'
               AND sr2.id = (SELECT MAX(sr3.id) FROM screening_results sr3 WHERE sr3.child_id = sr2.child_id)
            ) AS high_risk_count
          FROM projects p
          WHERE p.district_id = p_scope_id
          ORDER BY p.name
        ) sub
      )
    ) INTO result;

    RETURN result;

  -- ============================================================
  -- SCOPE = 'state' (for SENIOR_OFFICIAL)
  -- ============================================================
  ELSIF p_scope = 'state' THEN
    SELECT json_build_object(
      'scope', 'state',
      'total_districts', (
        SELECT COUNT(*) FROM districts WHERE state_id = p_scope_id
      ),
      'total_projects', (
        SELECT COUNT(*) FROM projects p
        JOIN districts d ON p.district_id = d.id
        WHERE d.state_id = p_scope_id
      ),
      'total_awcs', (
        SELECT COUNT(*) FROM anganwadi_centres ac
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        JOIN districts d ON p.district_id = d.id
        WHERE d.state_id = p_scope_id AND ac.is_active = true
      ),
      'total_children', (
        SELECT COUNT(*) FROM children c
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        JOIN districts d ON p.district_id = d.id
        WHERE d.state_id = p_scope_id AND c.is_active = true
      ),
      'screened_this_month', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        JOIN districts d ON p.district_id = d.id
        WHERE d.state_id = p_scope_id
          AND sr.created_at >= date_trunc('month', CURRENT_DATE)
      ),
      'high_risk_count', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        JOIN districts d ON p.district_id = d.id
        WHERE d.state_id = p_scope_id
          AND sr.overall_risk = 'HIGH'
          AND sr.id = (SELECT MAX(sr2.id) FROM screening_results sr2 WHERE sr2.child_id = sr.child_id)
      ),
      'referrals_needed', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        JOIN sectors s ON ac.sector_id = s.id
        JOIN projects p ON s.project_id = p.id
        JOIN districts d ON p.district_id = d.id
        WHERE d.state_id = p_scope_id
          AND sr.referral_needed = true
          AND sr.id = (SELECT MAX(sr2.id) FROM screening_results sr2 WHERE sr2.child_id = sr.child_id)
      ),
      'sub_units', (
        SELECT COALESCE(json_agg(row_to_json(sub)), '[]'::json)
        FROM (
          SELECT
            d.id,
            d.name,
            (SELECT COUNT(*) FROM projects p2 WHERE p2.district_id = d.id) AS sub_unit_count,
            (SELECT COUNT(*) FROM anganwadi_centres ac2
             JOIN sectors s2 ON ac2.sector_id = s2.id
             JOIN projects p2 ON s2.project_id = p2.id
             WHERE p2.district_id = d.id AND ac2.is_active = true) AS awc_count,
            (SELECT COUNT(*) FROM children c2
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             JOIN sectors s2 ON ac2.sector_id = s2.id
             JOIN projects p2 ON s2.project_id = p2.id
             WHERE p2.district_id = d.id AND c2.is_active = true) AS children_count,
            (SELECT COUNT(DISTINCT sr2.child_id) FROM screening_results sr2
             JOIN children c2 ON sr2.child_id = c2.id
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             JOIN sectors s2 ON ac2.sector_id = s2.id
             JOIN projects p2 ON s2.project_id = p2.id
             WHERE p2.district_id = d.id
               AND sr2.created_at >= date_trunc('month', CURRENT_DATE)) AS screened_count,
            (SELECT COUNT(DISTINCT sr2.child_id) FROM screening_results sr2
             JOIN children c2 ON sr2.child_id = c2.id
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             JOIN sectors s2 ON ac2.sector_id = s2.id
             JOIN projects p2 ON s2.project_id = p2.id
             WHERE p2.district_id = d.id AND sr2.overall_risk = 'HIGH'
               AND sr2.id = (SELECT MAX(sr3.id) FROM screening_results sr3 WHERE sr3.child_id = sr2.child_id)
            ) AS high_risk_count,
            (SELECT COUNT(DISTINCT sr2.child_id) FROM screening_results sr2
             JOIN children c2 ON sr2.child_id = c2.id
             JOIN anganwadi_centres ac2 ON c2.awc_id = ac2.id
             JOIN sectors s2 ON ac2.sector_id = s2.id
             JOIN projects p2 ON s2.project_id = p2.id
             WHERE p2.district_id = d.id
               AND sr2.referral_needed = true
               AND sr2.id = (SELECT MAX(sr3.id) FROM screening_results sr3 WHERE sr3.child_id = sr2.child_id)
            ) AS referrals_needed
          FROM districts d
          WHERE d.state_id = p_scope_id
          ORDER BY d.name
        ) sub
      )
    ) INTO result;

    RETURN result;

  -- ============================================================
  -- SCOPE = 'sector' (for SUPERVISOR)
  -- ============================================================
  ELSIF p_scope = 'sector' THEN
    SELECT json_build_object(
      'scope', 'sector',
      'total_awcs', (
        SELECT COUNT(*) FROM anganwadi_centres ac
        WHERE ac.sector_id = p_scope_id AND ac.is_active = true
      ),
      'total_children', (
        SELECT COUNT(*) FROM children c
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        WHERE ac.sector_id = p_scope_id AND c.is_active = true
      ),
      'screened_this_month', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        WHERE ac.sector_id = p_scope_id
          AND sr.created_at >= date_trunc('month', CURRENT_DATE)
      ),
      'high_risk_count', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        WHERE ac.sector_id = p_scope_id
          AND sr.overall_risk = 'HIGH'
          AND sr.id = (
            SELECT MAX(sr2.id) FROM screening_results sr2 WHERE sr2.child_id = sr.child_id
          )
      ),
      'referrals_needed', (
        SELECT COUNT(DISTINCT sr.child_id) FROM screening_results sr
        JOIN children c ON sr.child_id = c.id
        JOIN anganwadi_centres ac ON c.awc_id = ac.id
        WHERE ac.sector_id = p_scope_id
          AND sr.referral_needed = true
          AND sr.id = (
            SELECT MAX(sr2.id) FROM screening_results sr2 WHERE sr2.child_id = sr.child_id
          )
      ),
      'sub_units', (
        SELECT COALESCE(json_agg(row_to_json(sub)), '[]'::json)
        FROM (
          SELECT
            ac.id,
            COALESCE(ac.name, ac.centre_code) AS name,
            ac.centre_code,
            (SELECT COUNT(*) FROM children c2
             WHERE c2.awc_id = ac.id AND c2.is_active = true) AS children_count,
            (SELECT COUNT(DISTINCT sr2.child_id) FROM screening_results sr2
             JOIN children c2 ON sr2.child_id = c2.id
             WHERE c2.awc_id = ac.id
               AND sr2.created_at >= date_trunc('month', CURRENT_DATE)) AS screened_count,
            (SELECT COUNT(DISTINCT sr2.child_id) FROM screening_results sr2
             JOIN children c2 ON sr2.child_id = c2.id
             WHERE c2.awc_id = ac.id AND sr2.overall_risk = 'HIGH'
               AND sr2.id = (SELECT MAX(sr3.id) FROM screening_results sr3 WHERE sr3.child_id = sr2.child_id)
            ) AS high_risk_count
          FROM anganwadi_centres ac
          WHERE ac.sector_id = p_scope_id AND ac.is_active = true
          ORDER BY ac.centre_code
        ) sub
      )
    ) INTO result;

    RETURN result;

  ELSE
    RETURN json_build_object('error', 'Invalid scope: ' || p_scope);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant access to authenticated users
GRANT EXECUTE ON FUNCTION get_dashboard_stats(TEXT, INT) TO authenticated;

-- Verify
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public' AND routine_name = 'get_dashboard_stats';
