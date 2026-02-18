-- ============================================================
-- Workforce & System Performance — Schema Extension
-- Run this in Supabase SQL Editor AFTER the base schema
-- Adds: workforce training records, parent engagement tracking
-- ============================================================

-- ============================================================
-- 1. WORKFORCE TRAINING TABLE
-- Tracks training of ICDS functionaries (CDPOs, Supervisors, AWWs)
-- ============================================================

CREATE TABLE IF NOT EXISTS workforce_training (
  id SERIAL PRIMARY KEY,
  functionary_role TEXT NOT NULL CHECK (functionary_role IN ('CDPO', 'SUPERVISOR', 'AWW', 'DW', 'CW', 'EO')),
  training_mode TEXT CHECK (training_mode IN ('Physical', 'Virtual', 'Hybrid')),
  training_completed BOOLEAN DEFAULT FALSE,
  training_date DATE DEFAULT CURRENT_DATE,
  scope_level TEXT CHECK (scope_level IN ('state', 'district', 'project', 'sector', 'awc')),
  scope_id INT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workforce_role ON workforce_training(functionary_role);
CREATE INDEX IF NOT EXISTS idx_workforce_scope ON workforce_training(scope_level, scope_id);

-- ============================================================
-- 2. PARENT ENGAGEMENT TABLE
-- Tracks parent digital access, sensitization, interventions
-- ============================================================

CREATE TABLE IF NOT EXISTS parent_engagement (
  id SERIAL PRIMARY KEY,
  child_id INT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  digital_access TEXT CHECK (digital_access IN ('Smartphone', 'Keypad', 'None')),
  sensitized BOOLEAN DEFAULT FALSE,
  sensitization_date DATE,
  interventions_assigned INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_parent_engagement_child ON parent_engagement(child_id);

-- ============================================================
-- 3. RLS POLICIES
-- ============================================================

ALTER TABLE workforce_training ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_engagement ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read workforce_training" ON workforce_training FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can insert workforce_training" ON workforce_training FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Users can read parent_engagement" ON parent_engagement FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can insert parent_engagement" ON parent_engagement FOR INSERT TO authenticated WITH CHECK (true);
