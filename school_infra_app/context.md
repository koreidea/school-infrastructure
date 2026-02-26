# Vidya Soudha — School Infrastructure Planning & Monitoring App

## 1. What Is This Project?

This is an **AI-powered Baseline Assessment and Validation (BAV) system** for school infrastructure planning in Andhra Pradesh, India. It was built for **Problem Statement 5** of the **IndiaAI Innovation Challenge for Transforming Governance**, in collaboration with the Government of Andhra Pradesh.

**Problem Statement 5**: "AI Solutions for Scalable and Sustainable School Infrastructure Planning and Monitoring" — Department of School Education.

The app enables state, district, and block education officials to:
- **Forecast** infrastructure needs based on enrolment trends, demographics, and capacity
- **Validate** school-level demand plans against Samagra Shiksha norms (detect duplicates, inflated requests, anomalies)
- **Prioritise** infrastructure investments using AI-driven composite scoring
- **Monitor** infrastructure gaps across thousands of schools on an interactive map
- **Inspect** schools via offline-capable field assessments

---

## 2. Relationship to Bal Vikas App (Origin Codebase)

This project was derived from the **Bal Vikas App** (`../bal_vikas_app/`), which was built for the AP ECD (Early Childhood Development) Innovation Challenge. The Bal Vikas app is a screening platform for children aged 0-6 years.

**What was reused (~60-70% of architecture)**:
- Supabase auth + RLS + real-time sync infrastructure
- Flutter app scaffold, navigation, Riverpod state management patterns
- Dashboard framework & fl_chart visualization components
- Data export services (Excel/PDF generation patterns)
- Configurable admin rules engine pattern
- Localization framework (English + Telugu)
- API layer structure (Dio + FastAPI backend pattern)
- Offline-first sync architecture pattern

**What is new/significantly changed (~30-40%)**:
- Data models: School, Enrolment, DemandPlan, InfraAssessment, PriorityScore (replacing Child, Screening, Assessment)
- Prediction engine: Enrolment trend forecasting + infrastructure demand prediction (replacing developmental DQ scoring)
- Validation engine: Demand plan validation against Samagra Shiksha norms + ML anomaly detection
- Geospatial map view: Interactive school map with flutter_map (OpenStreetMap)
- Priority scoring: Composite infrastructure gap scoring (replacing developmental risk scoring)

**Conceptual entity mapping**:

| Bal Vikas (ECD) | Vidya Soudha (School Infra) |
|---|---|
| Child (0-6 yrs) | School |
| Anganwadi Centre | Mandal/Block |
| Developmental screening | Infrastructure assessment |
| Risk level (High/Medium/Low) | Priority level (Critical/High/Medium/Low) |
| Predict developmental delays | Predict infrastructure demand |
| AWW, Supervisor, CDPO roles | School HM, Block Officer, District Officer, State Official |
| Intervention recommendations | Infrastructure investment recommendations |

---

## 3. The Innovation Challenge

**Organiser**: IndiaAI (under Ministry of Electronics & IT) + Real Time Governance, AP Government

**Challenge Structure**:
- Stage 1: Solution development & refinement (submit via AIKosh portal)
- Stage 2: Finalising solution & deployment
- Up to 3 teams shortlisted per problem statement (INR 5 Lakhs each)
- Winner gets work contract up to INR 50 Lakhs for 1 year

**What Problem Statement 5 asks for**:
An AI-powered planning and validation system to create and maintain a **Baseline Assessment and Validation (BAV) model** for schools in AP, enabling:
1. Data-driven forecasting of infrastructure requirements (classrooms, sanitation, facilities, repair & maintenance)
2. Automated validation of school-level infrastructure proposals against historical trends, Samagra Shiksha norms, and predefined rules
3. Continuous planning, monitoring and prioritisation through departmental dashboards

**Evaluation criteria** (from guidelines.pdf):
- General: Approach/Innovation, Technical Feasibility, Product Roadmap, Team, Responsible AI, Data Policy compliance
- Technical: Data preparation, Model building, Model evaluation, Technical robustness (Accuracy, Precision, Recall, F1, AUC-ROC, Confusion Matrix)

---

## 4. Available Datasets

### 4.1 Sample Demand Plan Data for 2025
- **File**: `../Reference /Sample Demand Plan Data for 2025.xlsx`
- **Rows**: 319 schools across 26 AP districts
- **Columns (19)**: Sl.No, District Name, Mandal, School Code (UDISE), Latitude, Longitude, School Name, School Management, School Category, then 5 infrastructure categories each with Physical (count) + Financial (cost in Lakhs):
  - CWSN Resource Room (29.3L/unit)
  - CWSN Toilets (4.65L/unit)
  - Drinking Water (3.4L/unit)
  - Electrification (1.75L/unit)
  - Ramps & Handrails (1.25L/unit)
- **Key observations**: 244/319 are Primary Schools (PS), 284/319 are MPP/ZP managed, Ramps needed in nearly all schools

### 4.2 School Enrolment for Sample Data
- **File**: `../Reference /School Enrolment for Sample Data.xlsx`
- **Rows**: 956 (3 academic years x ~319 schools)
- **Columns (51)**: Academic_Year, UDISE_Code, district_name, block_name, School_Name, then grade-wise enrolment (Boys/Girls/Total) for PP3, PP2, PP1, C1 through C12, plus Total
- **Key observations**: 3 years of data (enabling trend analysis), classes 1-5 densest, median enrolment ~64 students, joinable with demand plan via UDISE code

### 4.3 Meta Information
- **File**: `../Reference /Meta Information of AI Kosh Sample Dataset.docx`
- Documents both Excel files with column descriptions and abbreviation keys

**Join key**: `UDISE_Code` (enrolment) = `School Code` (demand plan) — enables correlating enrolment levels with infrastructure needs.

---

## 5. Tech Stack

### Frontend
- **Flutter 3.10+** (Dart) — cross-platform mobile + web
- **Riverpod 3.x** — state management (uses `Notifier`/`NotifierProvider`, NOT legacy `StateProvider`/`StateNotifierProvider`)
- **fl_chart** — data visualisation (line, bar, pie charts)
- **flutter_map + latlong2** — OpenStreetMap-based interactive map (no API key needed)
- **excel** package — Excel generation for data export
- **pdf + printing** — PDF report generation
- **image_picker** — photo capture for field inspections
- **intl** — localisation (English + Telugu)
- **shared_preferences + hive** — local key-value storage
- **dio** — HTTP client for Python backend API

### Backend
- **Supabase** — PostgreSQL database, authentication (OTP), Row-Level Security, real-time subscriptions
- **FastAPI (Python)** — ML model serving, analytics endpoints
- **scikit-learn + pandas** — ML models for enrolment forecasting and anomaly detection

### AI/ML Approach (Hybrid)
- **Flutter-side (formula-based)**: Weighted composite scoring for priority classification, rule-based demand validation against Samagra Shiksha norms
- **Python-side (ML models)**:
  - Enrolment forecasting: Linear regression + cohort progression model
  - Anomaly detection: Isolation Forest for flagging unusual demand plans
  - Infrastructure need prediction: Formula-based gap calculation from forecast + norms

---

## 6. Database Schema

All tables prefixed with `si_` to avoid conflicts with Bal Vikas tables.

Full schema at: `supabase/schema.sql`

### Geographic Hierarchy
```
si_states → si_districts → si_mandals (blocks)
```

### Core Tables
```sql
si_schools (id, udise_code, school_name, district_id, mandal_id, latitude, longitude, school_management, school_category)

si_enrolment_history (id, school_id, academic_year, grade, boys, girls, total)  -- UNIQUE(school_id, academic_year, grade)

si_demand_plans (id, school_id, plan_year, infra_type, physical_count, financial_amount, validation_status, validation_score, validation_flags JSONB)

si_infra_assessments (id, school_id, assessed_by, assessment_date, existing_classrooms, existing_toilets, cwsn_toilet_available, cwsn_resource_room_available, drinking_water_available, electrification_status, ramp_available, condition_rating, photos JSONB, notes, synced)

si_enrolment_forecasts (id, school_id, forecast_year, grade, predicted_total, confidence, model_used)

si_school_priority_scores (id, school_id, score_year, composite_score, priority_level, enrolment_pressure_score, infra_gap_score, cwsn_need_score, accessibility_score, score_breakdown JSONB)  -- UNIQUE(school_id, score_year)

si_users (id, auth_uid UUID, name, phone, role, district_id, mandal_id, school_id)
```

### Views
- `si_schools_view` — Flat denormalized view joining schools with district, mandal, latest enrolment, and priority score
- `si_demand_plans_view` — Demand plans joined with school, district, mandal details

### Infrastructure Types
- `CWSN_RESOURCE_ROOM` — Resource rooms for Children With Special Needs
- `CWSN_TOILET` — Accessible toilets for CWSN
- `DRINKING_WATER` — Drinking water facilities
- `ELECTRIFICATION` — Electrical infrastructure
- `RAMPS` — Ramps and handrails for accessibility

### Validation Statuses
- `PENDING` → `APPROVED` | `FLAGGED` | `REJECTED`

### Priority Levels
- `CRITICAL` (score >80) — Immediate action needed
- `HIGH` (60-80) — Urgent attention required
- `MEDIUM` (40-60) — Planned intervention
- `LOW` (<40) — Monitoring only

---

## 7. User Roles & Access

| Role | Scope | Key Actions |
|---|---|---|
| SCHOOL_HM | Own school only | View profile, enrolment trends, demand status |
| BLOCK_OFFICER (MEO) | All schools in mandal | Priority ranking, validation queue, mandal analytics |
| DISTRICT_OFFICER (DEO) | All schools in district | Cross-mandal comparison, approval queue, district analytics |
| STATE_OFFICIAL | All schools statewide | State dashboard, district rankings, investment allocation |
| FIELD_INSPECTOR | Assigned schools | Conduct infrastructure assessments (offline-capable) |
| ADMIN | Full access | Configuration, user management, data imports |

---

## 8. App Architecture (Actual Files)

```
lib/
├── config/
│   └── api_config.dart              # SupabaseConfig, ApiConfig, AppColors, AppConstants
├── models/
│   ├── user.dart                    # AppUser, District, Mandal
│   ├── school.dart                  # School model with priorityColor getter
│   ├── enrolment.dart               # EnrolmentRecord, EnrolmentSummary, EnrolmentTrend, EnrolmentForecast
│   ├── demand_plan.dart             # DemandPlan (with cost anomaly detection), ValidationResult, DemandSummary
│   ├── infra_assessment.dart        # InfraAssessment with missingFacilitiesCount getter
│   └── priority_score.dart          # SchoolPriorityScore, PriorityDistribution
├── providers/
│   ├── auth_provider.dart           # CurrentUserNotifier (Notifier<AsyncValue<AppUser?>>)
│   ├── schools_provider.dart        # Filter notifiers, schoolsProvider, filteredSchoolsProvider
│   └── dashboard_provider.dart      # dashboardStatsProvider, demandSummaryProvider, priorityDistributionProvider
├── services/
│   ├── supabase_service.dart        # Full CRUD: getSchools(), getDemandPlans(), saveAssessment(), etc.
│   ├── api_service.dart             # Dio client for Python ML backend
│   ├── priority_scoring_service.dart # Composite scoring (4 weighted factors)
│   ├── demand_validation_service.dart # Rule-based validation (5 checks)
│   ├── excel_export_service.dart    # Multi-sheet Excel export (Schools, Demands, Priorities)
│   └── pdf_export_service.dart      # PDF school report cards
├── screens/
│   ├── auth/
│   │   └── role_selection_screen.dart  # 5 demo roles for quick access
│   ├── dashboard/
│   │   ├── dashboard_screen.dart       # 5-tab bottom navigation + IndexedStack
│   │   └── tabs/
│   │       ├── overview_tab.dart       # Stats grid, priority pie chart, demand summary
│   │       ├── schools_tab.dart        # Searchable school list with priority badges
│   │       ├── map_tab.dart            # FlutterMap with color-coded school markers
│   │       ├── validation_tab.dart     # 4-tab status filter (Pending/Flagged/Approved/Rejected)
│   │       └── analytics_tab.dart      # Bar charts, pie charts, metrics grid
│   ├── schools/
│   │   └── school_profile_screen.dart  # School info, enrolment trends, demand plans
│   └── inspection/
│       └── inspection_screen.dart      # Field assessment form (classrooms, CWSN, amenities)
└── main.dart                           # Entry point with SupabaseService.initialize()
```

---

## 9. Priority Scoring Algorithm

Composite score (0-100) based on 4 weighted factors:

| Factor | Weight | What It Measures |
|---|---|---|
| Enrolment Pressure | 30% | Growth rate, student-classroom ratio vs norms |
| Infrastructure Gap | 30% | Number of missing facilities, demand plan items |
| CWSN Needs | 20% | CWSN-specific gaps (resource rooms, toilets, ramps) |
| Accessibility | 20% | Electrification, drinking water, ramp availability |

**Priority classification**: CRITICAL (>80), HIGH (60-80), MEDIUM (40-60), LOW (<40)

Implementation: `lib/services/priority_scoring_service.dart`

---

## 10. Demand Validation Rules (Samagra Shiksha Norms)

The validation engine checks demand plan proposals against:
1. **Unit cost validation**: Flag if cost deviates >20% from standard unit costs
2. **Duplicate detection**: Same school + same infra type + same year
3. **Enrolment-demand correlation**: Flag if demand exceeds 3x expected for enrolment size
4. **Peer comparison**: Flag if outlier vs similar schools
5. **Zero-value checks**: Physical count or financial amount is zero

Output per proposal: `APPROVED` (score>=80) / `FLAGGED` (50-80) / `REJECTED` (<50) + confidence score + reason codes

Implementation: `lib/services/demand_validation_service.dart`

---

## 11. Python ML Backend

Located in `../school-infra-backend/` (FastAPI)

### Setup
```bash
cd school-infra-backend
pip install -r requirements.txt
export SUPABASE_URL=...
export SUPABASE_SERVICE_KEY=...
uvicorn app.main:app --reload
```

### Endpoints
- `POST /api/forecast/enrolment/{school_id}` — Predict next year enrolment
- `POST /api/forecast/batch` — Batch forecast all schools
- `POST /api/validate/demand-plan` — ML anomaly detection on demand plans
- `POST /api/validate/batch` — Batch validate all pending demands
- `GET /api/analytics/district/{district_id}` — District aggregated analytics
- `GET /api/analytics/state` — State-level summary
- `GET /health` — Health check

### ML Models
1. **Enrolment Forecasting** (`app/services/forecast_service.py`): Linear regression on 3-year grade-wise trends + cohort progression model (track students moving through grades)
2. **Anomaly Detection** (`app/services/validation_service.py`): Isolation Forest to flag unusual demand plan proposals + rule-based validation
3. **Infrastructure Need Prediction**: `gap = ceil(predicted_enrolment / norm_ratio) - existing_count`

---

## 12. Data Seeding

To populate the database from Excel files:
```bash
cd school_infra_app/supabase
export SUPABASE_SERVICE_KEY='your-service-role-key'
python seed_data.py
```

This will:
1. Create AP state
2. Extract unique districts/mandals from both Excel files
3. Insert schools from the demand plan (319 schools)
4. Insert demand plans per infra type per school
5. Insert 3 years of grade-wise enrolment data

---

## 13. Key Business Logic

### Samagra Shiksha
Samagra Shiksha is an integrated scheme of the Government of India for school education covering pre-school to Class 12. It provides funding for school infrastructure including classrooms, toilets, drinking water, electrification, and accessibility features. Demand plans are submitted by schools/districts annually and must be validated against scheme norms.

### CWSN
Children With Special Needs — schools must provide accessible infrastructure including resource rooms, accessible toilets, and ramps with handrails.

### UDISE Code
Unified District Information System for Education — unique identifier for every school in India. Used as the join key between datasets.

### School Categories
- **PS** — Primary School (Classes 1-5)
- **UPS** — Upper Primary School (Classes 6-8)
- **HS** — High School (Classes 9-10)
- **HSS** — Higher Secondary School (Classes 11-12)

### School Management Types
- **MPP_ZP** — Mandal Parishad / Zilla Parishad (local government)
- **GOVT** — State Government
- **AIDED** — Government-aided private
- **PRIVATE** — Unaided private

---

## 14. Supabase Configuration

- **URL**: `https://yiihjrxfupuohxzubusv.supabase.co`
- **Table prefix**: `si_` (all tables start with this prefix)
- **RLS**: Enabled with anon read access for demo mode
- **Schema file**: `supabase/schema.sql` — run this in Supabase SQL Editor to create all tables

---

## 15. File References

### Reference Documents (in `../Reference /`)
- `guidelines.pdf` — IndiaAI Innovation Challenge guidelines (21 pages). Problem Statement 5 is on pages 12-13.
- `ECD innovation challenge.pdf` — Original ECD challenge (the Bal Vikas app was built for this)
- `Sample Demand Plan Data for 2025.xlsx` — 319 schools, infrastructure demand data
- `School Enrolment for Sample Data.xlsx` — 956 rows, 3-year enrolment data
- `Meta Information of AI Kosh Sample Dataset.docx` — Dataset documentation

### Original Codebase (in `../bal_vikas_app/`)
- Full ECD screening platform source code
- Key reusable patterns: services/, providers/, screens/dashboard/, config/

---

## 16. Development Notes

- **Riverpod 3.x**: Uses `Notifier`/`NotifierProvider` (NOT legacy `StateProvider`/`StateNotifierProvider` which were removed)
- **Supabase project**: Currently shares the same Supabase instance as Bal Vikas (separate `si_` prefixed tables). For production, create a dedicated project.
- **Supabase URL**: `https://yiihjrxfupuohxzubusv.supabase.co` — this is the correct URL for both Flutter app and Python backend.
- **Map tiles**: Uses OpenStreetMap via flutter_map — no API key required, free for use.
- **Offline capability**: NOT YET IMPLEMENTED. Hive/connectivity_plus are in pubspec.yaml but never initialized. App is online-only.
- **Localisation**: NOT YET IMPLEMENTED. `Locale('te')` declared but no `.arb` files exist. App is English-only.
- **Data privacy**: Compliant with DPDP Act 2023. School data is non-PII but still follows role-based access controls.
- **Demo mode**: App starts with role selection (no auth required, no real Supabase Auth). Select any role to see the dashboard with demo user (id=0).
- **Flutter SDK**: Requires ^3.10.8

---

## 17. Implementation Status Audit (as of 2026-02-18)

### What's Working (End-to-End with Real Supabase Data)

| Feature | Status | Details |
|---|---|---|
| Role selection screen | Working | 5 demo roles, sets in-memory AppUser |
| Schools list (Schools tab) | Working | 319 schools from `si_schools_view`, search + priority filter |
| School profile screen | Working | Enrolment trend chart (fl_chart), demand plans list |
| Map view (Map tab) | Working | flutter_map + OSM, color-coded markers, tap → school popup |
| Validation tab (read) | Working | 799 demand plans loaded, 4 status tabs (Pending/Flagged/Approved/Rejected) |
| Overview tab (partial) | Partially working | Stats cards load from Supabase, but demand summary section is broken (see bugs) |
| Supabase data pipeline | Working | Schema deployed, 319 schools + 799 demands + 4638 enrolment records seeded |

### What's Missing / Broken

#### Critical: Services Exist but Never Called from UI (Dead Code)

| # | Feature | Service File | Problem |
|---|---|---|---|
| 1 | Priority Scoring | `priority_scoring_service.dart` | Never called. All priority scores are `None`. No UI trigger to compute them. |
| 2 | Demand Validation write-back | `demand_validation_service.dart` | "AI Validate" button in validation_tab is display-only dialog. Does NOT call the service or write results back to Supabase. |
| 3 | ML Backend integration | `api_service.dart` | Never imported or called from any screen/provider. Python backend is unreachable from the app. |
| 4 | Excel/PDF Export | `excel_export_service.dart`, `pdf_export_service.dart` | Fully coded but no export buttons exist anywhere in the app. |
| 5 | Inspection Screen | `inspection_screen.dart` | Fully built form but orphaned — no navigation path reaches it from any screen. |

#### Critical: Broken / Wrong Data

| # | Issue | Location | Details |
|---|---|---|---|
| 6 | Analytics Tab hardcoded | `analytics_tab.dart` | 100% static demo data. Does not use any provider or real Supabase data. |
| 7 | Overview demand summary type mismatch | `overview_tab.dart` | Provider returns `List<DemandSummary>` but widget checks `is List<DemandSummaryDisplay>` — always shows "No demand plan data". |
| 8 | Python backend wrong Supabase URL | `school-infra-backend/app/services/db.py` + `.env.example` | Points to `eutyixqhwgcfwtgtjyis` (wrong) instead of `yiihjrxfupuohxzubusv` (correct). |
| 9 | Unit cost mismatch | Backend vs Flutter | CWSN Resource Room: backend uses ₹2.93L, Flutter `api_config.dart` uses ₹29.3L (10x difference). |

#### Missing Features (per Problem Statement Requirements)

| # | Feature | Status |
|---|---|---|
| 10 | Offline capability | Hive, connectivity_plus in pubspec but never initialized. App is 100% online-only. |
| 11 | Photo capture in inspections | image_picker in pubspec but never used. Photos array always `[]`. |
| 12 | Telugu localization | `Locale('te')` declared but no `.arb` files exist. English-only. |
| 13 | District/Mandal filter dropdowns | Providers exist (`selectedDistrictProvider`, `selectedMandalProvider`) but no filter dropdown UI in Schools tab. |
| 14 | Role-based data scoping | All roles see all 319 schools. No district/mandal filtering based on user's role scope. |
| 15 | Map marker clustering | Not implemented. 319+ markers rendered individually (may be slow). |
| 16 | Responsible AI documentation | Needs explicit write-up for evaluation submission. |

### Priority Order for Remaining Work

**Must-fix (app fails evaluation without these):**
1. Wire `PriorityScoringService` — compute & save scores for all 319 schools (enables priority badges + map colors)
2. Fix Analytics Tab — replace hardcoded data with real provider data
3. Wire `DemandValidationService` — make "AI Validate" validate and write results back to Supabase
4. Fix Overview Tab demand summary type mismatch bug
5. Add navigation to Inspection Screen (from school profile)
6. Add Export buttons (Excel/PDF) to dashboard or school profile
7. Fix Python backend Supabase URL to match Flutter app

**Should-fix (strengthens evaluation score):**
8. Wire `ApiService` to call Python ML backend for enrolment forecasting
9. Add district/mandal filter dropdowns to Schools tab
10. Fix CWSN Resource Room unit cost mismatch (backend ₹2.93L vs app ₹29.3L)

**Nice-to-have (if time permits):**
11. Offline support with Hive
12. Telugu localization (`.arb` files)
13. Photo capture in inspections
14. Role-based data scoping
