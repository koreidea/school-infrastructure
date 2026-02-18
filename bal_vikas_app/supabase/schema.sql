-- ============================================================
-- Bal Vikas ECD App — Supabase Database Schema
-- Run this FIRST in Supabase SQL Editor
-- ============================================================

-- Enable UUID extension (usually already enabled in Supabase)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. GEOGRAPHIC HIERARCHY
-- ============================================================

CREATE TABLE states (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE districts (
  id SERIAL PRIMARY KEY,
  state_id INT NOT NULL REFERENCES states(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE projects (
  id SERIAL PRIMARY KEY,
  district_id INT NOT NULL REFERENCES districts(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE sectors (
  id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. ANGANWADI CENTRES
-- ============================================================

CREATE TABLE anganwadi_centres (
  id SERIAL PRIMARY KEY,
  sector_id INT NOT NULL REFERENCES sectors(id) ON DELETE CASCADE,
  centre_code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  address TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. USERS (all roles)
-- ============================================================

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_uid UUID UNIQUE,  -- links to Supabase auth.users.id
  phone TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN (
    'PARENT', 'AWW', 'SUPERVISOR', 'CDPO',
    'DW', 'CW', 'EO', 'SENIOR_OFFICIAL'
  )),
  email TEXT,
  dob DATE,
  doj DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  qualification TEXT,
  -- Hierarchy links (only one applies per role)
  state_id INT REFERENCES states(id),
  district_id INT REFERENCES districts(id),
  project_id INT REFERENCES projects(id),
  sector_id INT REFERENCES sectors(id),
  awc_id INT REFERENCES anganwadi_centres(id),
  preferred_language TEXT DEFAULT 'en',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for quick phone lookup during auth
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_auth_uid ON users(auth_uid);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================
-- 4. CHILDREN
-- ============================================================

CREATE TABLE children (
  id SERIAL PRIMARY KEY,
  child_unique_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  dob DATE NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
  awc_id INT NOT NULL REFERENCES anganwadi_centres(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES users(id),
  aww_id UUID REFERENCES users(id),
  photo_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_children_awc ON children(awc_id);
CREATE INDEX idx_children_parent ON children(parent_id);
CREATE INDEX idx_children_aww ON children(aww_id);

-- ============================================================
-- 5. SCREENING SESSIONS
-- ============================================================

CREATE TABLE screening_sessions (
  id SERIAL PRIMARY KEY,
  child_id INT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  conducted_by UUID REFERENCES users(id),
  assessment_date DATE NOT NULL,
  child_age_months INT NOT NULL,
  status TEXT NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ,
  device_session_id TEXT  -- local ID for sync conflict resolution
);

CREATE INDEX idx_sessions_child ON screening_sessions(child_id);
CREATE INDEX idx_sessions_conducted_by ON screening_sessions(conducted_by);
CREATE INDEX idx_sessions_device ON screening_sessions(device_session_id);

-- ============================================================
-- 6. SCREENING RESPONSES (individual question answers)
-- ============================================================

CREATE TABLE screening_responses (
  id SERIAL PRIMARY KEY,
  session_id INT NOT NULL REFERENCES screening_sessions(id) ON DELETE CASCADE,
  tool_type TEXT NOT NULL,
  question_id TEXT NOT NULL,
  response_value JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_responses_session ON screening_responses(session_id);
CREATE INDEX idx_responses_tool ON screening_responses(tool_type);

-- ============================================================
-- 7. SCREENING RESULTS (computed scores per session)
-- ============================================================

CREATE TABLE screening_results (
  id SERIAL PRIMARY KEY,
  session_id INT NOT NULL REFERENCES screening_sessions(id) ON DELETE CASCADE,
  child_id INT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  overall_risk TEXT NOT NULL CHECK (overall_risk IN ('LOW', 'MEDIUM', 'HIGH')),
  overall_risk_te TEXT,
  referral_needed BOOLEAN DEFAULT FALSE,
  gm_dq DOUBLE PRECISION,
  fm_dq DOUBLE PRECISION,
  lc_dq DOUBLE PRECISION,
  cog_dq DOUBLE PRECISION,
  se_dq DOUBLE PRECISION,
  composite_dq DOUBLE PRECISION,
  tool_results JSONB,
  concerns JSONB,
  concerns_te JSONB,
  tools_completed INT DEFAULT 0,
  tools_skipped INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_results_session ON screening_results(session_id);
CREATE INDEX idx_results_child ON screening_results(child_id);

-- ============================================================
-- 8. AUTO-UPDATE TRIGGER for updated_at columns
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_children_updated_at
  BEFORE UPDATE ON children
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
