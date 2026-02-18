-- Screening Tool Configuration Tables for Admin UI
-- Run this in Supabase SQL Editor to create the config tables

-- 1. screening_tool_configs
CREATE TABLE IF NOT EXISTS screening_tool_configs (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tool_type     text NOT NULL UNIQUE,
  tool_id       text NOT NULL UNIQUE,
  name          text NOT NULL,
  name_te       text NOT NULL DEFAULT '',
  description   text DEFAULT '',
  description_te text DEFAULT '',
  min_age_months int DEFAULT 0,
  max_age_months int DEFAULT 72,
  response_format text NOT NULL,
  domains       jsonb DEFAULT '[]'::jsonb,
  icon_name     text,
  color_hex     text,
  sort_order    int DEFAULT 0,
  is_age_bracket_filtered boolean DEFAULT false,
  is_active     boolean DEFAULT true,
  version       int DEFAULT 1,
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

-- 2. screening_questions
CREATE TABLE IF NOT EXISTS screening_questions (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tool_config_id  bigint NOT NULL REFERENCES screening_tool_configs(id) ON DELETE CASCADE,
  code            text NOT NULL,
  text_en         text NOT NULL,
  text_te         text NOT NULL DEFAULT '',
  domain          text,
  domain_name_en  text,
  domain_name_te  text,
  category        text,
  category_te     text,
  age_months      int,
  is_critical     boolean DEFAULT false,
  is_red_flag     boolean DEFAULT false,
  is_reverse_scored boolean DEFAULT false,
  unit            text,
  override_format text,
  sort_order      int DEFAULT 0,
  is_active       boolean DEFAULT true,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);

-- 3. response_options
CREATE TABLE IF NOT EXISTS response_options (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tool_config_id  bigint NOT NULL REFERENCES screening_tool_configs(id) ON DELETE CASCADE,
  question_id     bigint REFERENCES screening_questions(id) ON DELETE SET NULL,
  label_en        text NOT NULL,
  label_te        text NOT NULL DEFAULT '',
  value           jsonb NOT NULL,
  color_hex       text,
  sort_order      int DEFAULT 0,
  created_at      timestamptz DEFAULT now()
);

-- 4. scoring_rules
CREATE TABLE IF NOT EXISTS scoring_rules (
  id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tool_config_id      bigint NOT NULL REFERENCES screening_tool_configs(id) ON DELETE CASCADE,
  rule_type           text NOT NULL,
  domain              text,
  parameter_name      text NOT NULL,
  parameter_value     jsonb NOT NULL,
  description         text,
  created_at          timestamptz DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_questions_tool ON screening_questions(tool_config_id);
CREATE INDEX IF NOT EXISTS idx_options_tool ON response_options(tool_config_id);
CREATE INDEX IF NOT EXISTS idx_rules_tool ON scoring_rules(tool_config_id);
CREATE INDEX IF NOT EXISTS idx_questions_active ON screening_questions(tool_config_id, is_active);

-- Enable RLS with permissive policies (hackathon demo)
ALTER TABLE screening_tool_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE screening_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE response_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE scoring_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all for authenticated" ON screening_tool_configs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON screening_questions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON response_options FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON scoring_rules FOR ALL USING (true) WITH CHECK (true);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_tool_configs BEFORE UPDATE ON screening_tool_configs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at_questions BEFORE UPDATE ON screening_questions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
