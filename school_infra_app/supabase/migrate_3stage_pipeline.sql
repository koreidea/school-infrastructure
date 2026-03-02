-- =============================================================================
-- Migration: 3-Stage Approval Pipeline
-- Run this against the Supabase SQL editor to add officer decision columns
-- and assessment linking to si_demand_plans.
-- =============================================================================

-- 1. Add new columns to si_demand_plans
ALTER TABLE si_demand_plans
  ADD COLUMN IF NOT EXISTS officer_status      TEXT DEFAULT 'PENDING',
  ADD COLUMN IF NOT EXISTS officer_name        TEXT,
  ADD COLUMN IF NOT EXISTS officer_reviewed_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS officer_notes       TEXT,
  ADD COLUMN IF NOT EXISTS assessment_id       INT REFERENCES si_infra_assessments(id) ON DELETE SET NULL;

-- 2. Add indexes
CREATE INDEX IF NOT EXISTS idx_si_demand_plans_officer_status ON si_demand_plans(officer_status);
CREATE INDEX IF NOT EXISTS idx_si_demand_plans_assessment_id  ON si_demand_plans(assessment_id);

-- 3. DROP and recreate the view (CREATE OR REPLACE can't add columns in the middle)
DROP VIEW IF EXISTS si_demand_plans_view;

CREATE VIEW si_demand_plans_view AS
SELECT
    dp.id,
    dp.plan_year,
    dp.infra_type,
    dp.physical_count,
    dp.financial_amount,
    -- Stage 1: AI Validation
    dp.validation_status,
    dp.validation_score,
    dp.validation_flags,
    dp.validated_by,
    dp.validated_at,
    -- Stage 3: Officer Decision
    dp.officer_status,
    dp.officer_name,
    dp.officer_reviewed_at,
    dp.officer_notes,
    -- Stage 2: Assessment Link
    dp.assessment_id,
    CASE WHEN ia.id IS NOT NULL THEN true ELSE false END AS has_assessment,
    ia.assessment_date       AS assessment_date,
    ia.condition_rating      AS assessment_condition,
    ia.assessed_by           AS assessment_by,
    -- School & geography joins
    dp.school_id,
    s.udise_code,
    s.school_name,
    s.school_management,
    s.school_category,
    d.id                    AS district_id,
    d.district_name,
    m.id                    AS mandal_id,
    m.mandal_name,
    dp.created_at,
    dp.updated_at
FROM si_demand_plans dp
JOIN si_schools     s  ON s.id  = dp.school_id
LEFT JOIN si_districts d  ON d.id  = s.district_id
LEFT JOIN si_mandals   m  ON m.id  = s.mandal_id
LEFT JOIN si_infra_assessments ia ON ia.id = dp.assessment_id;

-- 4. Data migration: move existing officer validations to officer_* columns
UPDATE si_demand_plans
SET
  officer_status      = validation_status,
  officer_name        = validated_by,
  officer_reviewed_at = validated_at,
  officer_notes       = NULL
WHERE validated_by IS NOT NULL
  AND validated_by != 'AI_VALIDATOR'
  AND officer_status = 'PENDING';

-- 5. Auto-link latest assessment for each demand plan (where assessment exists)
UPDATE si_demand_plans dp
SET assessment_id = sub.latest_assessment_id
FROM (
  SELECT DISTINCT ON (ia.school_id) ia.school_id, ia.id AS latest_assessment_id
  FROM si_infra_assessments ia
  ORDER BY ia.school_id, ia.assessment_date DESC
) sub
WHERE dp.school_id = sub.school_id
  AND dp.assessment_id IS NULL;
