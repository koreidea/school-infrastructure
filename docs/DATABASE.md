# Database Schema — Vidya Soudha

## Overview

Vidya Soudha uses **Supabase** (PostgreSQL) as its cloud database. All tables use the `si_` prefix to namespace school infrastructure data.

- **Supabase URL**: `https://yiihjrxfupuohxzubusv.supabase.co`
- **Auth**: Row-Level Security (RLS) enabled on all tables
- **Access**: Anon key for demo mode (read-only)

---

## Entity Relationship Diagram

```
si_districts (57)
  |
  +--< si_mandals (707)
  |      |
  |      +--< si_schools (319)
  |             |
  |             +--< si_demand_plans (799)
  |             +--< si_enrolment_records (4,638)
  |             +--< si_enrolment_history
  |             +--< si_school_priority_scores
  |             +--< si_infra_assessments
  |             +--< si_enrolment_forecasts
  |
  si_users (0 — demo mode uses in-memory)
```

---

## Tables

### si_districts
Master table of 57 districts in Andhra Pradesh.

| Column | Type | Description |
|--------|------|-------------|
| id | integer (PK) | Auto-increment ID |
| district_code | varchar | Unique district code |
| district_name | varchar | District name (e.g., "Anantapur") |
| state | varchar | State name ("Andhra Pradesh") |
| created_at | timestamptz | Creation timestamp |

**Key Notes**: Column is `district_name`, NOT `name`.

---

### si_mandals
Master table of 707 mandals (sub-district administrative units).

| Column | Type | Description |
|--------|------|-------------|
| id | integer (PK) | Auto-increment ID |
| mandal_code | varchar | Unique mandal code |
| mandal_name | varchar | Mandal name |
| district_id | integer (FK) | References si_districts(id) |
| created_at | timestamptz | Creation timestamp |

---

### si_schools
Master table of 319 schools with static metadata.

| Column | Type | Description |
|--------|------|-------------|
| id | integer (PK) | Auto-increment ID |
| udise_code | varchar | Unique UDISE school code |
| school_name | varchar | Full school name |
| district_id | integer (FK) | References si_districts(id) |
| mandal_id | integer (FK) | References si_mandals(id) |
| school_category | varchar | PS, UPS, HS, HSS |
| management_type | varchar | MPP_ZP, GOVT, AIDED, PRIVATE |
| latitude | double | GPS latitude |
| longitude | double | GPS longitude |
| total_enrolment | integer | Current total enrolment |
| total_teachers | integer | Number of teachers |
| num_classrooms | integer | Number of classrooms |
| has_electricity | boolean | Electrification status |
| has_drinking_water | boolean | Water availability |
| has_cwsn_toilet | boolean | CWSN toilet available |
| has_cwsn_ramp | boolean | Ramp available |
| has_cwsn_resource_room | boolean | CWSN resource room |
| created_at | timestamptz | Creation timestamp |

**Categories**: PS (Primary School), UPS (Upper Primary), HS (High School), HSS (Higher Secondary)
**Management**: MPP_ZP (Mandal/Zilla Parishad), GOVT (Government), AIDED (Aided), PRIVATE (Private)

---

### si_demand_plans
Infrastructure demand proposals submitted by schools (799 records).

| Column | Type | Description |
|--------|------|-------------|
| id | integer (PK) | Auto-increment ID |
| school_id | integer (FK) | References si_schools(id) |
| infra_type | varchar | CWSN_RESOURCE_ROOM, CWSN_TOILET, DRINKING_WATER, ELECTRIFICATION, RAMPS |
| physical_count | integer | Number of units requested |
| financial_amount | double | Cost in Lakhs |
| justification | text | Demand justification text |
| validation_status | varchar | PENDING, APPROVED, FLAGGED, REJECTED |
| validation_score | double | AI validation score (0-100) |
| validation_flags | text[] | Array of flag codes |
| validated_by | varchar | Officer name (null if AI-only) |
| validated_at | timestamptz | Validation timestamp |
| validation_method | varchar | AI, OFFICER, or null |
| academic_year | varchar | e.g., "2024-25" |
| created_at | timestamptz | Creation timestamp |

**Unit Costs (Lakhs)**: CWSN_RESOURCE_ROOM: 29.3L, CWSN_TOILET: 4.65L, DRINKING_WATER: 3.4L, ELECTRIFICATION: 1.75L, RAMPS: 1.25L

---

### si_enrolment_records
Year/grade enrolment data (4,638 records across multiple academic years).

| Column | Type | Description |
|--------|------|-------------|
| id | integer (PK) | Auto-increment ID |
| school_id | integer (FK) | References si_schools(id) |
| academic_year | varchar | e.g., "2022-23", "2023-24" |
| grade | varchar | Grade level (1-12, ALL) |
| boys | integer | Number of boys enrolled |
| girls | integer | Number of girls enrolled |
| total | integer | Total enrolment |
| created_at | timestamptz | Creation timestamp |

---

### si_school_priority_scores
Computed composite priority scores for resource allocation.

| Column | Type | Description |
|--------|------|-------------|
| id | integer (PK) | Auto-increment ID |
| school_id | integer (FK, unique) | References si_schools(id) |
| composite_score | double | Overall priority score (0-100) |
| priority_level | varchar | CRITICAL, HIGH, MEDIUM, LOW |
| enrolment_score | double | Enrolment pressure factor (0-100) |
| infra_gap_score | double | Infrastructure gap factor (0-100) |
| cwsn_score | double | CWSN needs factor (0-100) |
| accessibility_score | double | Accessibility factor (0-100) |
| computed_at | timestamptz | When scores were computed |
| created_at | timestamptz | Creation timestamp |

**Scoring Formula**: `composite = (enrolment * 0.30) + (infra_gap * 0.30) + (cwsn * 0.20) + (accessibility * 0.20)`

---

### si_infra_assessments
Field inspection data submitted by inspectors.

| Column | Type | Description |
|--------|------|-------------|
| id | integer (PK) | Auto-increment ID |
| school_id | integer (FK) | References si_schools(id) |
| assessor_name | varchar | Inspector name |
| assessor_role | varchar | FIELD_INSPECTOR or BLOCK_OFFICER |
| num_classrooms | integer | Observed classroom count |
| num_toilets | integer | Observed toilet count |
| has_cwsn_resource_room | boolean | CWSN room present |
| has_cwsn_toilet | boolean | CWSN toilet present |
| has_ramp | boolean | Accessibility ramp |
| has_drinking_water | boolean | Water facility |
| electrification_status | varchar | Electrified, Partially, None |
| overall_condition | varchar | Good, Needs Repair, Critical, Dilapidated |
| photo_urls | text[] | Array of photo evidence URLs |
| notes | text | Inspector notes |
| assessed_at | timestamptz | Assessment timestamp |
| created_at | timestamptz | Creation timestamp |

---

### si_enrolment_forecasts
ML-generated enrolment predictions (populated by backend).

| Column | Type | Description |
|--------|------|-------------|
| id | integer (PK) | Auto-increment ID |
| school_id | integer (FK) | References si_schools(id) |
| forecast_year | varchar | Predicted year (e.g., "2026-27") |
| grade | varchar | Grade or "ALL" |
| predicted_total | integer | Predicted enrolment |
| confidence | double | Prediction confidence (0-1) |
| model_used | varchar | LinearRegression, CohortProgression |
| created_at | timestamptz | Creation timestamp |

---

### si_users
User accounts table (currently empty — app uses demo login).

| Column | Type | Description |
|--------|------|-------------|
| id | uuid (PK) | Supabase Auth UID |
| email | varchar | User email |
| role | varchar | STATE_OFFICIAL, DISTRICT_OFFICER, etc. |
| full_name | varchar | Display name |
| district_id | integer (FK) | Assigned district (nullable) |
| mandal_id | integer (FK) | Assigned mandal (nullable) |
| school_id | integer (FK) | Assigned school (nullable) |
| created_at | timestamptz | Creation timestamp |

---

## Database Views

### si_schools_view
Joins schools with district/mandal names and latest priority score.

```sql
SELECT s.*, d.district_name, m.mandal_name,
       p.composite_score, p.priority_level
FROM si_schools s
LEFT JOIN si_districts d ON s.district_id = d.id
LEFT JOIN si_mandals m ON s.mandal_id = m.id
LEFT JOIN si_school_priority_scores p ON s.id = p.school_id
```

### si_demand_plans_view
Joins demand plans with school and district info.

```sql
SELECT dp.*, s.school_name, s.udise_code,
       d.district_name, m.mandal_name
FROM si_demand_plans dp
JOIN si_schools s ON dp.school_id = s.id
LEFT JOIN si_districts d ON s.district_id = d.id
LEFT JOIN si_mandals m ON s.mandal_id = m.id
```

---

## Row-Level Security (RLS)

All tables have RLS enabled. Key policies:

```sql
-- Allow read access for authenticated users
CREATE POLICY "Allow read" ON si_schools
  FOR SELECT USING (true);

-- Restrict write to appropriate roles
CREATE POLICY "Officers can validate" ON si_demand_plans
  FOR UPDATE USING (
    auth.jwt() ->> 'role' IN ('STATE_OFFICIAL', 'DISTRICT_OFFICER', 'BLOCK_OFFICER')
  );

-- Inspectors can insert assessments
CREATE POLICY "Inspectors write assessments" ON si_infra_assessments
  FOR INSERT WITH CHECK (
    auth.jwt() ->> 'role' IN ('FIELD_INSPECTOR', 'BLOCK_OFFICER')
  );
```

**Note**: Demo mode uses anon key with read-only access. Production would use authenticated JWT tokens with role claims.

---

## PostgreSQL Notes

- `CREATE POLICY IF NOT EXISTS` is **NOT valid syntax** — always use `DROP POLICY IF EXISTS ... ; CREATE POLICY ...`
- Supabase `.in_()` filter limited to ~500 items — app fetches all and filters in Dart for large sets
- All timestamps stored as `timestamptz` (UTC)
- Text arrays (`text[]`) used for `validation_flags` and `photo_urls`
