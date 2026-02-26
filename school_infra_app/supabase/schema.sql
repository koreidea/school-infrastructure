-- =============================================================================
-- School Infrastructure Planning App — Supabase Schema
-- =============================================================================
-- All tables are prefixed with "si_" to avoid conflicts in a shared project.
-- Execute this file once against the Supabase SQL editor or via psql.
-- Safe to re-run: tables/indexes use IF NOT EXISTS, views use OR REPLACE,
-- policies use DROP IF EXISTS + CREATE.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. GEOGRAPHIC HIERARCHY
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS si_states (
    id          SERIAL PRIMARY KEY,
    state_name  TEXT NOT NULL UNIQUE,
    state_code  TEXT UNIQUE,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS si_districts (
    id             SERIAL PRIMARY KEY,
    state_id       INT NOT NULL REFERENCES si_states(id) ON DELETE CASCADE,
    district_name  TEXT NOT NULL,
    district_code  TEXT,
    created_at     TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at     TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (state_id, district_name)
);

CREATE TABLE IF NOT EXISTS si_mandals (
    id            SERIAL PRIMARY KEY,
    district_id   INT NOT NULL REFERENCES si_districts(id) ON DELETE CASCADE,
    mandal_name   TEXT NOT NULL,
    mandal_code   TEXT,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at    TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (district_id, mandal_name)
);

-- ---------------------------------------------------------------------------
-- 2. SCHOOLS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS si_schools (
    id                 SERIAL PRIMARY KEY,
    udise_code         BIGINT UNIQUE NOT NULL,
    school_name        TEXT NOT NULL,
    district_id        INT REFERENCES si_districts(id) ON DELETE SET NULL,
    mandal_id          INT REFERENCES si_mandals(id) ON DELETE SET NULL,
    latitude           DOUBLE PRECISION,
    longitude          DOUBLE PRECISION,
    school_management  TEXT,
    school_category    TEXT,
    created_at         TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at         TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 3. ENROLMENT HISTORY
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS si_enrolment_history (
    id             SERIAL PRIMARY KEY,
    school_id      INT NOT NULL REFERENCES si_schools(id) ON DELETE CASCADE,
    academic_year  TEXT NOT NULL,
    grade          TEXT NOT NULL,
    boys           INT DEFAULT 0,
    girls          INT DEFAULT 0,
    total          INT DEFAULT 0,
    created_at     TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at     TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (school_id, academic_year, grade)
);

-- ---------------------------------------------------------------------------
-- 4. DEMAND PLANS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS si_demand_plans (
    id                  SERIAL PRIMARY KEY,
    school_id           INT NOT NULL REFERENCES si_schools(id) ON DELETE CASCADE,
    plan_year           INT NOT NULL,
    infra_type          TEXT NOT NULL,
    physical_count      INT DEFAULT 0,
    financial_amount    DOUBLE PRECISION DEFAULT 0,
    validation_status   TEXT DEFAULT 'PENDING',
    validation_score    DOUBLE PRECISION,
    validation_flags    JSONB DEFAULT '[]'::jsonb,
    validated_by        TEXT,
    validated_at        TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 5. INFRASTRUCTURE ASSESSMENTS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS si_infra_assessments (
    id                           SERIAL PRIMARY KEY,
    school_id                    INT NOT NULL REFERENCES si_schools(id) ON DELETE CASCADE,
    assessed_by                  TEXT,
    assessment_date              DATE NOT NULL DEFAULT CURRENT_DATE,
    existing_classrooms          INT DEFAULT 0,
    existing_toilets             INT DEFAULT 0,
    cwsn_toilet_available        BOOLEAN DEFAULT false,
    cwsn_resource_room_available BOOLEAN DEFAULT false,
    drinking_water_available     BOOLEAN DEFAULT false,
    electrification_status       TEXT,
    ramp_available               BOOLEAN DEFAULT false,
    condition_rating             TEXT,
    photos                       JSONB DEFAULT '[]'::jsonb,
    notes                        TEXT,
    synced                       BOOLEAN DEFAULT false,
    created_at                   TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at                   TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 6. ENROLMENT FORECASTS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS si_enrolment_forecasts (
    id               SERIAL PRIMARY KEY,
    school_id        INT NOT NULL REFERENCES si_schools(id) ON DELETE CASCADE,
    forecast_year    TEXT NOT NULL,
    grade            TEXT NOT NULL,
    predicted_total  INT DEFAULT 0,
    confidence       DOUBLE PRECISION,
    model_used       TEXT,
    created_at       TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 7. USERS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS si_users (
    id          SERIAL PRIMARY KEY,
    auth_uid    UUID UNIQUE,
    name        TEXT,
    phone       TEXT,
    role        TEXT,
    district_id INT REFERENCES si_districts(id) ON DELETE SET NULL,
    mandal_id   INT REFERENCES si_mandals(id) ON DELETE SET NULL,
    school_id   INT REFERENCES si_schools(id) ON DELETE SET NULL,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 8. SCHOOL PRIORITY SCORES
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS si_school_priority_scores (
    id                        SERIAL PRIMARY KEY,
    school_id                 INT NOT NULL REFERENCES si_schools(id) ON DELETE CASCADE,
    score_year                INT NOT NULL,
    composite_score           DOUBLE PRECISION,
    priority_level            TEXT,
    enrolment_pressure_score  DOUBLE PRECISION,
    infra_gap_score           DOUBLE PRECISION,
    cwsn_need_score           DOUBLE PRECISION,
    accessibility_score       DOUBLE PRECISION,
    score_breakdown           JSONB DEFAULT '{}'::jsonb,
    computed_at               TIMESTAMP WITH TIME ZONE DEFAULT now(),
    created_at                TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at                TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (school_id, score_year)
);

-- =============================================================================
-- INDEXES
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_si_districts_state_id       ON si_districts(state_id);
CREATE INDEX IF NOT EXISTS idx_si_mandals_district_id      ON si_mandals(district_id);
CREATE INDEX IF NOT EXISTS idx_si_schools_district_id      ON si_schools(district_id);
CREATE INDEX IF NOT EXISTS idx_si_schools_mandal_id        ON si_schools(mandal_id);
CREATE INDEX IF NOT EXISTS idx_si_schools_udise_code       ON si_schools(udise_code);
CREATE INDEX IF NOT EXISTS idx_si_schools_management       ON si_schools(school_management);
CREATE INDEX IF NOT EXISTS idx_si_schools_category         ON si_schools(school_category);
CREATE INDEX IF NOT EXISTS idx_si_enrolment_history_school ON si_enrolment_history(school_id);
CREATE INDEX IF NOT EXISTS idx_si_enrolment_history_year   ON si_enrolment_history(academic_year);
CREATE INDEX IF NOT EXISTS idx_si_demand_plans_school      ON si_demand_plans(school_id);
CREATE INDEX IF NOT EXISTS idx_si_demand_plans_year        ON si_demand_plans(plan_year);
CREATE INDEX IF NOT EXISTS idx_si_demand_plans_status      ON si_demand_plans(validation_status);
CREATE INDEX IF NOT EXISTS idx_si_demand_plans_infra_type  ON si_demand_plans(infra_type);
CREATE INDEX IF NOT EXISTS idx_si_infra_assessments_school ON si_infra_assessments(school_id);
CREATE INDEX IF NOT EXISTS idx_si_infra_assessments_date   ON si_infra_assessments(assessment_date);
CREATE INDEX IF NOT EXISTS idx_si_infra_assessments_synced ON si_infra_assessments(synced);
CREATE INDEX IF NOT EXISTS idx_si_enrolment_forecasts_school ON si_enrolment_forecasts(school_id);
CREATE INDEX IF NOT EXISTS idx_si_enrolment_forecasts_year ON si_enrolment_forecasts(forecast_year);
CREATE INDEX IF NOT EXISTS idx_si_users_auth_uid           ON si_users(auth_uid);
CREATE INDEX IF NOT EXISTS idx_si_users_role               ON si_users(role);
CREATE INDEX IF NOT EXISTS idx_si_users_district_id        ON si_users(district_id);
CREATE INDEX IF NOT EXISTS idx_si_users_mandal_id          ON si_users(mandal_id);
CREATE INDEX IF NOT EXISTS idx_si_users_school_id          ON si_users(school_id);
CREATE INDEX IF NOT EXISTS idx_si_priority_scores_school   ON si_school_priority_scores(school_id);
CREATE INDEX IF NOT EXISTS idx_si_priority_scores_year     ON si_school_priority_scores(score_year);
CREATE INDEX IF NOT EXISTS idx_si_priority_scores_level    ON si_school_priority_scores(priority_level);
CREATE INDEX IF NOT EXISTS idx_si_priority_scores_composite ON si_school_priority_scores(composite_score DESC);

-- =============================================================================
-- VIEWS
-- =============================================================================

CREATE OR REPLACE VIEW si_schools_view AS
SELECT
    s.id,
    s.udise_code,
    s.school_name,
    s.school_management,
    s.school_category,
    s.latitude,
    s.longitude,
    d.id                    AS district_id,
    d.district_name,
    m.id                    AS mandal_id,
    m.mandal_name,
    e.total_enrolment       AS total_enrolment,
    p.composite_score       AS priority_score,
    p.priority_level,
    s.created_at,
    s.updated_at
FROM si_schools s
LEFT JOIN si_districts d ON d.id = s.district_id
LEFT JOIN si_mandals   m ON m.id = s.mandal_id
LEFT JOIN LATERAL (
    SELECT SUM(eh.total) AS total_enrolment
    FROM si_enrolment_history eh
    WHERE eh.school_id = s.id
    GROUP BY eh.academic_year
    ORDER BY eh.academic_year DESC
    LIMIT 1
) e ON true
LEFT JOIN LATERAL (
    SELECT ps.composite_score, ps.priority_level
    FROM si_school_priority_scores ps
    WHERE ps.school_id = s.id
    ORDER BY ps.score_year DESC
    LIMIT 1
) p ON true;

CREATE OR REPLACE VIEW si_demand_plans_view AS
SELECT
    dp.id,
    dp.plan_year,
    dp.infra_type,
    dp.physical_count,
    dp.financial_amount,
    dp.validation_status,
    dp.validation_score,
    dp.validation_flags,
    dp.validated_by,
    dp.validated_at,
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
JOIN si_schools     s ON s.id = dp.school_id
LEFT JOIN si_districts d ON d.id = s.district_id
LEFT JOIN si_mandals   m ON m.id = s.mandal_id;

-- =============================================================================
-- RLS POLICIES
-- =============================================================================

ALTER TABLE si_schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE si_enrolment_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE si_demand_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE si_infra_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE si_school_priority_scores ENABLE ROW LEVEL SECURITY;

-- Allow anon read access for demo mode
DROP POLICY IF EXISTS "anon_read_schools" ON si_schools;
CREATE POLICY "anon_read_schools" ON si_schools FOR SELECT USING (true);

DROP POLICY IF EXISTS "anon_read_enrolment" ON si_enrolment_history;
CREATE POLICY "anon_read_enrolment" ON si_enrolment_history FOR SELECT USING (true);

DROP POLICY IF EXISTS "anon_read_demands" ON si_demand_plans;
CREATE POLICY "anon_read_demands" ON si_demand_plans FOR SELECT USING (true);

DROP POLICY IF EXISTS "anon_read_assessments" ON si_infra_assessments;
CREATE POLICY "anon_read_assessments" ON si_infra_assessments FOR SELECT USING (true);

DROP POLICY IF EXISTS "anon_read_priority" ON si_school_priority_scores;
CREATE POLICY "anon_read_priority" ON si_school_priority_scores FOR SELECT USING (true);

-- Allow authenticated users to insert/update
DROP POLICY IF EXISTS "auth_write_demands" ON si_demand_plans;
CREATE POLICY "auth_write_demands" ON si_demand_plans FOR ALL USING (true);

DROP POLICY IF EXISTS "auth_write_assessments" ON si_infra_assessments;
CREATE POLICY "auth_write_assessments" ON si_infra_assessments FOR ALL USING (true);

DROP POLICY IF EXISTS "auth_write_priority" ON si_school_priority_scores;
CREATE POLICY "auth_write_priority" ON si_school_priority_scores FOR ALL USING (true);

-- =============================================================================
-- SEED: AP State
-- =============================================================================
INSERT INTO si_states (state_name, state_code) VALUES ('Andhra Pradesh', 'AP')
ON CONFLICT (state_name) DO NOTHING;
