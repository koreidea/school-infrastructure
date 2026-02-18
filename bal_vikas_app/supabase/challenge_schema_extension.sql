-- ============================================================
-- ECD Challenge Dashboard — Schema Extension
-- Run this in Supabase SQL Editor AFTER the base schema
-- Adds: baseline risk scoring, referrals, nutrition,
--        environment, intervention follow-ups
-- ============================================================

-- ============================================================
-- 1. EXTEND screening_results WITH CHALLENGE FIELDS
-- ============================================================

ALTER TABLE screening_results
  ADD COLUMN IF NOT EXISTS assessment_cycle TEXT DEFAULT 'Baseline'
    CHECK (assessment_cycle IN ('Baseline', 'Follow-up', 'Re-screen')),
  ADD COLUMN IF NOT EXISTS baseline_score INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS baseline_category TEXT DEFAULT 'Low'
    CHECK (baseline_category IN ('Low', 'Medium', 'High')),
  ADD COLUMN IF NOT EXISTS num_delays INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS autism_risk TEXT DEFAULT 'Low'
    CHECK (autism_risk IN ('Low', 'Moderate', 'High')),
  ADD COLUMN IF NOT EXISTS adhd_risk TEXT DEFAULT 'Low'
    CHECK (adhd_risk IN ('Low', 'Moderate', 'High')),
  ADD COLUMN IF NOT EXISTS behavior_risk TEXT DEFAULT 'Low'
    CHECK (behavior_risk IN ('Low', 'Moderate', 'High')),
  ADD COLUMN IF NOT EXISTS behavior_score INT DEFAULT 0;

-- Update overall_risk constraint to allow existing values + new scoring
-- (Keep LOW/MEDIUM/HIGH as-is; baseline_category handles the challenge's risk tiers)

-- ============================================================
-- 2. REFERRALS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS referrals (
  id SERIAL PRIMARY KEY,
  child_id INT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  screening_result_id INT REFERENCES screening_results(id) ON DELETE SET NULL,
  session_id INT REFERENCES screening_sessions(id) ON DELETE SET NULL,
  referral_triggered BOOLEAN DEFAULT FALSE,
  referral_type TEXT CHECK (referral_type IN (
    'PHC', 'RBSK', 'DEIC', 'NRC', 'AWW_INTERVENTION', 'PARENT_INTERVENTION'
  )),
  referral_reason TEXT CHECK (referral_reason IN (
    'GDD', 'ADHD', 'AUTISM', 'BEHAVIOUR', 'ENVIRONMENT', 'DOMAIN_DELAY'
  )),
  referral_status TEXT DEFAULT 'Pending' CHECK (referral_status IN (
    'Pending', 'Completed', 'Under_Treatment'
  )),
  referred_by UUID REFERENCES users(id),
  referred_date DATE DEFAULT CURRENT_DATE,
  completed_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_referrals_child ON referrals(child_id);
CREATE INDEX IF NOT EXISTS idx_referrals_status ON referrals(referral_status);
CREATE INDEX IF NOT EXISTS idx_referrals_result ON referrals(screening_result_id);

-- Auto-update trigger
CREATE TRIGGER update_referrals_updated_at
  BEFORE UPDATE ON referrals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 3. NUTRITION ASSESSMENTS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS nutrition_assessments (
  id SERIAL PRIMARY KEY,
  child_id INT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  session_id INT REFERENCES screening_sessions(id) ON DELETE SET NULL,
  height_cm DOUBLE PRECISION,
  weight_kg DOUBLE PRECISION,
  muac_cm DOUBLE PRECISION,
  underweight BOOLEAN DEFAULT FALSE,
  stunting BOOLEAN DEFAULT FALSE,
  wasting BOOLEAN DEFAULT FALSE,
  anemia BOOLEAN DEFAULT FALSE,
  nutrition_score INT DEFAULT 0,
  nutrition_risk TEXT DEFAULT 'Low' CHECK (nutrition_risk IN ('Low', 'Moderate', 'High')),
  assessed_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_nutrition_child ON nutrition_assessments(child_id);
CREATE INDEX IF NOT EXISTS idx_nutrition_session ON nutrition_assessments(session_id);

-- ============================================================
-- 4. ENVIRONMENT / CAREGIVING ASSESSMENTS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS environment_assessments (
  id SERIAL PRIMARY KEY,
  child_id INT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  session_id INT REFERENCES screening_sessions(id) ON DELETE SET NULL,
  parent_child_interaction_score INT CHECK (parent_child_interaction_score BETWEEN 1 AND 5),
  parent_mental_health_score INT CHECK (parent_mental_health_score BETWEEN 1 AND 10),
  home_stimulation_score INT CHECK (home_stimulation_score BETWEEN 1 AND 10),
  play_materials BOOLEAN DEFAULT FALSE,
  caregiver_engagement TEXT CHECK (caregiver_engagement IN ('Low', 'Medium', 'High')),
  language_exposure TEXT CHECK (language_exposure IN ('Adequate', 'Inadequate')),
  safe_water BOOLEAN DEFAULT FALSE,
  toilet_facility BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_environment_child ON environment_assessments(child_id);
CREATE INDEX IF NOT EXISTS idx_environment_session ON environment_assessments(session_id);

-- ============================================================
-- 5. INTERVENTION FOLLOW-UPS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS intervention_followups (
  id SERIAL PRIMARY KEY,
  child_id INT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  screening_result_id INT REFERENCES screening_results(id) ON DELETE SET NULL,
  intervention_plan_generated BOOLEAN DEFAULT FALSE,
  home_activities_assigned INT DEFAULT 0,
  followup_conducted BOOLEAN DEFAULT FALSE,
  followup_date DATE,
  next_followup_date DATE,
  improvement_status TEXT CHECK (improvement_status IN ('Improved', 'Same', 'Worsened')),
  reduction_in_delay_months INT DEFAULT 0,
  domain_improvement BOOLEAN DEFAULT FALSE,
  autism_risk_change TEXT DEFAULT 'Same' CHECK (autism_risk_change IN ('Improved', 'Same', 'Worsened')),
  exit_high_risk BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_followup_child ON intervention_followups(child_id);
CREATE INDEX IF NOT EXISTS idx_followup_result ON intervention_followups(screening_result_id);
CREATE INDEX IF NOT EXISTS idx_followup_status ON intervention_followups(improvement_status);

-- ============================================================
-- 6. RLS POLICIES (Row Level Security)
-- ============================================================

-- Enable RLS on new tables
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE environment_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE intervention_followups ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read/write (simple policy for now)
CREATE POLICY "Users can read referrals" ON referrals FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can insert referrals" ON referrals FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Users can update referrals" ON referrals FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Users can read nutrition" ON nutrition_assessments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can insert nutrition" ON nutrition_assessments FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Users can read environment" ON environment_assessments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can insert environment" ON environment_assessments FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Users can read followups" ON intervention_followups FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can insert followups" ON intervention_followups FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Users can update followups" ON intervention_followups FOR UPDATE TO authenticated USING (true);
