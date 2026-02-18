-- ============================================================
-- Bal Vikas ECD App — Screening Tool Configuration Schema
-- Run this AFTER schema.sql
--
-- This file creates 5 tables for storing screening tool
-- configurations, questions, response options, scoring rules,
-- and developmental activities. These tables drive the
-- screening UI from the database rather than hardcoded Dart.
-- ============================================================

-- ============================================================
-- 0. ENSURE updated_at TRIGGER FUNCTION EXISTS
-- (idempotent — safe to re-run if schema.sql already created it)
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 1. SCREENING TOOL CONFIGS
--    One row per screening tool (11 tools total).
--    tool_type matches the Dart enum name exactly.
-- ============================================================

CREATE TABLE screening_tool_configs (
  id              SERIAL       PRIMARY KEY,
  tool_type       TEXT         NOT NULL UNIQUE,
  tool_id         TEXT         NOT NULL UNIQUE,
  name            TEXT         NOT NULL,
  name_te         TEXT         NOT NULL,
  description     TEXT,
  description_te  TEXT,
  min_age_months  INTEGER      NOT NULL DEFAULT 0,
  max_age_months  INTEGER      NOT NULL DEFAULT 72,
  response_format TEXT         NOT NULL CHECK (response_format IN (
                    'yesNo', 'threePoint', 'fourPoint',
                    'fivePoint', 'numericInput', 'mixed'
                  )),
  domains         JSONB        DEFAULT '[]'::JSONB,
  icon_name       TEXT,
  color_hex       TEXT,
  sort_order      INTEGER      NOT NULL DEFAULT 0,
  is_age_bracket_filtered BOOLEAN NOT NULL DEFAULT FALSE,
  is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
  version         INTEGER      NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ  DEFAULT NOW(),
  updated_at      TIMESTAMPTZ  DEFAULT NOW()
);

COMMENT ON TABLE screening_tool_configs IS
  'Master configuration for each screening tool. tool_type maps to the Dart ScreeningToolType enum.';

COMMENT ON COLUMN screening_tool_configs.tool_type IS
  'Dart enum name: cdcMilestones, rbskTool, mchatAutism, isaaAutism, adhdScreening, rbskBehavioral, sdqBehavioral, parentChildInteraction, parentMentalHealth, homeStimulation, nutritionAssessment';

COMMENT ON COLUMN screening_tool_configs.response_format IS
  'Determines the UI input widget: yesNo (2 options), threePoint (3 options), fourPoint (4 options), fivePoint (5 options), numericInput (free text number), mixed (per-question override)';

-- Index on sort_order for ordered listing
CREATE INDEX idx_tool_configs_sort ON screening_tool_configs(sort_order);

-- Index on is_active for filtering
CREATE INDEX idx_tool_configs_active ON screening_tool_configs(is_active) WHERE is_active = TRUE;

-- Auto-update trigger
CREATE TRIGGER update_screening_tool_configs_updated_at
  BEFORE UPDATE ON screening_tool_configs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 2. SCREENING QUESTIONS
--    Individual questions belonging to a screening tool.
--    Supports bilingual text, domain grouping, age brackets,
--    critical/red-flag markers, and nutrition unit overrides.
-- ============================================================

CREATE TABLE screening_questions (
  id              SERIAL       PRIMARY KEY,
  tool_config_id  INTEGER      NOT NULL REFERENCES screening_tool_configs(id) ON DELETE CASCADE,
  code            TEXT         NOT NULL,
  text_en         TEXT         NOT NULL,
  text_te         TEXT         NOT NULL,
  domain          TEXT,
  domain_name_en  TEXT,
  domain_name_te  TEXT,
  category        TEXT,
  category_te     TEXT,
  age_months      INTEGER,
  is_critical     BOOLEAN      NOT NULL DEFAULT FALSE,
  is_red_flag     BOOLEAN      NOT NULL DEFAULT FALSE,
  is_reverse_scored BOOLEAN    NOT NULL DEFAULT FALSE,
  unit            TEXT,
  override_format TEXT         CHECK (override_format IS NULL OR override_format IN (
                    'yesNo', 'threePoint', 'fourPoint',
                    'fivePoint', 'numericInput'
                  )),
  sort_order      INTEGER      NOT NULL DEFAULT 0,
  is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ  DEFAULT NOW()
);

-- Each question code must be unique within its tool
ALTER TABLE screening_questions
  ADD CONSTRAINT uq_question_code_per_tool UNIQUE (tool_config_id, code);

COMMENT ON TABLE screening_questions IS
  'Individual screening questions. code is the question identifier (e.g. gm_2_1, mchat_1). Grouped by tool and optionally by domain/age bracket.';

COMMENT ON COLUMN screening_questions.age_months IS
  'For age-bracket-filtered tools (e.g. CDC Milestones): the target age in months this question applies to.';

COMMENT ON COLUMN screening_questions.unit IS
  'For nutrition assessment numeric inputs: cm, kg, etc.';

COMMENT ON COLUMN screening_questions.override_format IS
  'Per-question response format override for mixed-format tools (e.g. nutritionAssessment).';

-- Index for fetching questions by tool
CREATE INDEX idx_questions_tool ON screening_questions(tool_config_id);

-- Index for age-bracket filtering (CDC milestones)
CREATE INDEX idx_questions_age ON screening_questions(tool_config_id, age_months)
  WHERE age_months IS NOT NULL;

-- Index for domain grouping
CREATE INDEX idx_questions_domain ON screening_questions(tool_config_id, domain);

-- Index on sort_order for ordered display
CREATE INDEX idx_questions_sort ON screening_questions(tool_config_id, sort_order);

-- Index for active questions only
CREATE INDEX idx_questions_active ON screening_questions(is_active) WHERE is_active = TRUE;

-- ============================================================
-- 3. RESPONSE OPTIONS
--    Named response choices for tools with custom options.
--    When question_id IS NULL the options apply to all
--    questions in the tool (shared options).
-- ============================================================

CREATE TABLE response_options (
  id              SERIAL       PRIMARY KEY,
  tool_config_id  INTEGER      NOT NULL REFERENCES screening_tool_configs(id) ON DELETE CASCADE,
  question_id     INTEGER      REFERENCES screening_questions(id) ON DELETE CASCADE,
  label_en        TEXT         NOT NULL,
  label_te        TEXT         NOT NULL,
  value           JSONB        NOT NULL,
  color_hex       TEXT,
  sort_order      INTEGER      NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ  DEFAULT NOW()
);

COMMENT ON TABLE response_options IS
  'Named response options for tools with custom scales. question_id NULL means shared across all questions in the tool.';

COMMENT ON COLUMN response_options.value IS
  'Numeric value stored as JSONB for flexibility (e.g. 0, 1, 2, 3).';

-- Index for fetching options by tool (shared options)
CREATE INDEX idx_response_options_tool ON response_options(tool_config_id)
  WHERE question_id IS NULL;

-- Index for fetching options by specific question
CREATE INDEX idx_response_options_question ON response_options(question_id)
  WHERE question_id IS NOT NULL;

-- Index on sort_order for ordered display
CREATE INDEX idx_response_options_sort ON response_options(tool_config_id, sort_order);

-- ============================================================
-- 4. SCORING RULES
--    Thresholds, cutoffs, and classification rules for each
--    tool. Supports both domain-level and overall scoring.
-- ============================================================

CREATE TABLE scoring_rules (
  id              SERIAL       PRIMARY KEY,
  tool_config_id  INTEGER      NOT NULL REFERENCES screening_tool_configs(id) ON DELETE CASCADE,
  rule_type       TEXT         NOT NULL,
  domain          TEXT,
  parameter_name  TEXT         NOT NULL,
  parameter_value JSONB        NOT NULL,
  description     TEXT,
  created_at      TIMESTAMPTZ  DEFAULT NOW()
);

COMMENT ON TABLE scoring_rules IS
  'Scoring thresholds and classification rules per tool. domain NULL means the rule applies to the overall/composite score.';

COMMENT ON COLUMN scoring_rules.rule_type IS
  'Type of scoring rule: threshold, cutoff, formula, classification.';

COMMENT ON COLUMN scoring_rules.parameter_name IS
  'Named parameter, e.g. dq_threshold, low_risk_max, medium_risk_max, high_risk_min, total_score_max.';

COMMENT ON COLUMN scoring_rules.parameter_value IS
  'The threshold/cutoff value stored as JSONB (e.g. 75, 0.85, {"min": 0, "max": 10}).';

-- Unique index using COALESCE to handle nullable domain
CREATE UNIQUE INDEX uq_scoring_rule
  ON scoring_rules (tool_config_id, rule_type, COALESCE(domain, '__overall__'), parameter_name);

-- Index for fetching rules by tool
CREATE INDEX idx_scoring_rules_tool ON scoring_rules(tool_config_id);

-- Index for fetching rules by tool and domain
CREATE INDEX idx_scoring_rules_tool_domain ON scoring_rules(tool_config_id, domain);

-- Index for fetching rules by type
CREATE INDEX idx_scoring_rules_type ON scoring_rules(rule_type);

-- ============================================================
-- 5. ACTIVITIES
--    Developmental activities recommended based on screening
--    results. Bilingual, filterable by domain, age, and risk.
-- ============================================================

CREATE TABLE activities (
  id               SERIAL       PRIMARY KEY,
  activity_code    TEXT         NOT NULL UNIQUE,
  domain           TEXT         NOT NULL,
  title_en         TEXT         NOT NULL,
  title_te         TEXT         NOT NULL,
  description_en   TEXT         NOT NULL,
  description_te   TEXT         NOT NULL,
  materials_en     TEXT,
  materials_te     TEXT,
  duration_minutes INTEGER      NOT NULL DEFAULT 15,
  min_age_months   INTEGER      NOT NULL DEFAULT 0,
  max_age_months   INTEGER      NOT NULL DEFAULT 72,
  risk_level       TEXT         NOT NULL DEFAULT 'all' CHECK (risk_level IN (
                     'all', 'low', 'medium', 'high'
                   )),
  has_video        BOOLEAN      NOT NULL DEFAULT FALSE,
  is_active        BOOLEAN      NOT NULL DEFAULT TRUE,
  version          INTEGER      NOT NULL DEFAULT 1,
  created_at       TIMESTAMPTZ  DEFAULT NOW(),
  updated_at       TIMESTAMPTZ  DEFAULT NOW()
);

COMMENT ON TABLE activities IS
  'Developmental activities recommended after screening. Filterable by domain, age range, and risk level.';

COMMENT ON COLUMN activities.risk_level IS
  'Which risk level this activity targets: all (universal), low, medium, or high.';

-- Index for filtering by domain
CREATE INDEX idx_activities_domain ON activities(domain);

-- Index for age-range filtering
CREATE INDEX idx_activities_age ON activities(min_age_months, max_age_months);

-- Index for risk-level filtering
CREATE INDEX idx_activities_risk ON activities(risk_level);

-- Index for active activities
CREATE INDEX idx_activities_active ON activities(is_active) WHERE is_active = TRUE;

-- Composite index for the most common query pattern: domain + age + risk + active
CREATE INDEX idx_activities_lookup ON activities(domain, risk_level, min_age_months, max_age_months)
  WHERE is_active = TRUE;

-- Auto-update trigger
CREATE TRIGGER update_activities_updated_at
  BEFORE UPDATE ON activities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 6. ROW LEVEL SECURITY
--    All config tables are read-only reference data.
--    Any authenticated user can SELECT; only service_role
--    (admin/migration) can INSERT/UPDATE/DELETE.
-- ============================================================

-- Enable RLS on all config tables
ALTER TABLE screening_tool_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE screening_questions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE response_options        ENABLE ROW LEVEL SECURITY;
ALTER TABLE scoring_rules           ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities              ENABLE ROW LEVEL SECURITY;

-- screening_tool_configs: authenticated read access
CREATE POLICY "Authenticated users can read screening tool configs"
  ON screening_tool_configs FOR SELECT
  TO authenticated
  USING (true);

-- screening_questions: authenticated read access
CREATE POLICY "Authenticated users can read screening questions"
  ON screening_questions FOR SELECT
  TO authenticated
  USING (true);

-- response_options: authenticated read access
CREATE POLICY "Authenticated users can read response options"
  ON response_options FOR SELECT
  TO authenticated
  USING (true);

-- scoring_rules: authenticated read access
CREATE POLICY "Authenticated users can read scoring rules"
  ON scoring_rules FOR SELECT
  TO authenticated
  USING (true);

-- activities: authenticated read access
CREATE POLICY "Authenticated users can read activities"
  ON activities FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================
-- SUMMARY
-- ============================================================
--
-- Tables created:
--   1. screening_tool_configs  — 11 tool definitions
--   2. screening_questions     — per-tool questions (bilingual)
--   3. response_options        — custom response scales
--   4. scoring_rules           — thresholds & classification
--   5. activities              — recommended developmental activities
--
-- Security:
--   - RLS enabled on all 5 tables
--   - Authenticated users: SELECT only
--   - Service role: full access (bypasses RLS)
--
-- Triggers:
--   - updated_at auto-updates on screening_tool_configs
--   - updated_at auto-updates on activities
--
-- Indexes:
--   - Optimized for common query patterns:
--     tool lookup, domain grouping, age-bracket filtering,
--     sort ordering, active-only filtering, activity lookup
-- ============================================================
