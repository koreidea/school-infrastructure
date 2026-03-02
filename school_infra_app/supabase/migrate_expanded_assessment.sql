-- =============================================================================
-- Migration: Expanded Infrastructure Assessment Fields
-- Run this against the Supabase SQL editor to add detailed inspection fields
-- to si_infra_assessments.
-- =============================================================================

-- 1. Toilet Breakdown
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS boys_toilets              INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS girls_toilets             INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS functional_toilets        INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS handwash_available        BOOLEAN DEFAULT false;

-- 2. Classroom Quality
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS functional_classrooms     INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS furniture_adequacy        TEXT DEFAULT 'Adequate';

-- 3. Boundary Wall
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS boundary_wall             TEXT DEFAULT 'None';

-- 4. Water Source
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS water_source_type         TEXT DEFAULT 'None',
  ADD COLUMN IF NOT EXISTS water_purifier_available  BOOLEAN DEFAULT false;

-- 5. Kitchen / Mid-Day Meal
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS mdm_kitchen_available     BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS mdm_kitchen_condition     TEXT DEFAULT 'Non-Functional';

-- 6. Library
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS library_available         BOOLEAN DEFAULT false;

-- 7. Computer / ICT Lab
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS computer_lab_available    BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS functional_computers      INT DEFAULT 0;

-- 8. Safety Equipment
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS fire_extinguisher_available BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS first_aid_available       BOOLEAN DEFAULT false;

-- 9. GPS Auto-Capture
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS inspection_latitude       DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS inspection_longitude      DOUBLE PRECISION;

-- 10. Per-Infra Condition Ratings
ALTER TABLE si_infra_assessments
  ADD COLUMN IF NOT EXISTS building_condition        TEXT DEFAULT 'Good',
  ADD COLUMN IF NOT EXISTS toilet_condition          TEXT DEFAULT 'Good',
  ADD COLUMN IF NOT EXISTS electrical_condition      TEXT DEFAULT 'Good';
