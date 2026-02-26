# Vidya Soudha — Project Context for Claude Code

## What Is This?
**Vidya Soudha (విద్యా సౌధ)** — AI-powered School Infrastructure Planning & Monitoring App for **IndiaAI Innovation Challenge Problem Statement 5** (Dept of School Education, Andhra Pradesh). Flutter + Supabase + FastAPI.

## Tech Stack
- **Frontend**: Flutter 3.10+ with Riverpod 3.x, fl_chart, flutter_map
- **Backend**: FastAPI (Python) — ML forecasting + validation
- **Database**: Supabase (PostgreSQL + Auth + RLS)
- **Supabase URL**: `https://yiihjrxfupuohxzubusv.supabase.co`

## Project Structure
```
school_infra_app/          # Flutter app (main codebase)
  lib/
    config/api_config.dart   # Constants, colors, unit costs, Supabase config
    models/                  # School, DemandPlan, EnrolmentRecord, PriorityScore, AppUser, InfraAssessment
    services/                # supabase_service, api_service, validation, scoring, export, offline cache
    providers/               # Riverpod providers (auth, schools, dashboard, locale)
    screens/
      auth/role_selection_screen.dart
      dashboard/dashboard_screen.dart + tabs/ (overview, schools, map, validation, analytics)
      schools/school_profile_screen.dart
      inspection/inspection_screen.dart
    l10n/app_localizations.dart  # English + Telugu
school-infra-backend/      # Python FastAPI ML backend
  app/main.py              # FastAPI app, 3 routers: forecast, validate, analytics
  app/services/forecast_service.py   # Linear regression + cohort progression
  app/services/validation_service.py # Rule-based + Isolation Forest
start_backend.sh           # Creates venv, installs deps, runs uvicorn on :8000
Reference/                 # IndiaAI sample data (Excel files, guidelines)
```

## Database (Supabase)
All tables use `si_` prefix. Key column names: `district_name` (not `name`), `mandal_name`, `district_code`, `mandal_code`.

| Table | Purpose | Rows |
|---|---|---|
| si_schools | School master data | 319 |
| si_schools_view | View with joined district/mandal/priority | — |
| si_districts | District master | 57 |
| si_mandals | Mandal master | 707 |
| si_demand_plans | Infrastructure demand plans | 799 |
| si_demand_plans_view | View with joined school/district info | — |
| si_enrolment_records / si_enrolment_history | Year/grade enrolment | 4,638 |
| si_school_priority_scores | Composite priority scores | computed on first launch |
| si_infra_assessments | Field inspector data | — |
| si_enrolment_forecasts | ML forecasts | — |
| si_users | User accounts (currently empty; app uses demo login) | 0 |

## Roles & Permissions
5 roles with role-based data scoping. Demo login via role selection screen (no real auth).

| Role | Sees | Can Validate | Can Inspect |
|---|---|---|---|
| STATE_OFFICIAL | All schools | Yes | No |
| DISTRICT_OFFICER | Own district | Yes | No |
| BLOCK_OFFICER | Own mandal | Yes | Yes |
| FIELD_INSPECTOR | Own mandal | No | Yes |
| SCHOOL_HM | Own school only | No | No |

Key permission getters on `AppUser`: `canValidate`, `canViewAllSchools`, `canViewMap`, `canExport`, `canInspect`.

## Infrastructure Types & Unit Costs (Lakhs)
From `AppConstants` in api_config.dart:
- CWSN_RESOURCE_ROOM: 29.3L
- CWSN_TOILET: 4.65L
- DRINKING_WATER: 3.4L
- ELECTRIFICATION: 1.75L
- RAMPS: 1.25L

## AI/ML Features

### 1. Priority Scoring (Flutter client-side)
Composite score 0–100, weighted: Enrolment Pressure (30%) + Infrastructure Gap (30%) + CWSN Needs (20%) + Accessibility (20%).
Levels: CRITICAL >80, HIGH >60, MEDIUM >40, LOW ≤40.
Service: `priority_scoring_service.dart`. Auto-computed on first dashboard load if scores table is empty.

### 2. Demand Validation
**Client-side** (DemandValidationService): 5 rules — unit cost deviation, duplicates, enrolment correlation, peer comparison, zero-value checks. Score 0–100 → APPROVED (≥80), FLAGGED (50–79), REJECTED (<50).
**Backend** (validation_service.py): Same rules + Isolation Forest ML anomaly detection.
Officers can also manually Approve/Flag/Reject via the Validation tab.

### 3. Enrolment Forecasting
**Client-side fallback** (dashboard_provider.dart): Uses `EnrolmentTrend.compute()` growth rate, projects 3 years with declining confidence (90%→70%→50%).
**Backend** (forecast_service.py): Linear regression + cohort progression model.
App tries backend first, falls back to client-side if offline.

## Riverpod 3.x Patterns (IMPORTANT)
- Uses `Notifier`/`NotifierProvider` — NOT `StateProvider`/`StateNotifierProvider` (removed in 3.x)
- Filter notifiers use `.set(value)` method, not `.state = value`
- AsyncValue pattern matching: `switch (async) { case AsyncData(:final value): ... }`
- Reference pattern: `providers/schools_provider.dart`
- Role-based scoping: `effectiveDistrictProvider`, `effectiveMandalProvider`, `effectiveSchoolIdProvider` lock data based on user role

## Key Providers
| Provider | Type | Purpose |
|---|---|---|
| currentUserProvider | NotifierProvider<AsyncValue<AppUser?>> | Current demo user |
| schoolsProvider | FutureProvider<List<School>> | Schools list (role-scoped + offline fallback) |
| demandPlansProvider | FutureProvider<List<DemandPlan>> | Demand plans (role-scoped + offline cache) |
| dashboardStatsProvider | FutureProvider<Map> | Overview stats |
| priorityScoresProvider | FutureProvider<List<SchoolPriorityScore>> | All priority scores |
| schoolPriorityScoreProvider | FutureProvider.family<SchoolPriorityScore?, int> | Single school score |
| validateDemandProvider | NotifierProvider<AsyncValue<String?>> | AI + manual validation |
| forecastProvider | NotifierProvider<AsyncValue<Map?>> | Enrolment forecast |
| computePriorityScoresProvider | NotifierProvider<AsyncValue<String?>> | Batch score computation |
| effectiveDistrictProvider | Provider<int?> | Role-locked district filter |
| effectiveMandalProvider | Provider<int?> | Role-locked mandal filter |
| effectiveSchoolIdProvider | Provider<int?> | School HM's school |

## Screens & Navigation
```
RoleSelectionScreen → DashboardScreen (5 tabs via BottomNavigationBar)
  ├── OverviewTab      — Stats cards, priority pie chart, demand summary (tappable → other tabs)
  ├── SchoolsTab       — Filterable list → SchoolProfileScreen (enrolment chart, forecast, demand plans, priority breakdown)
  ├── MapTab           — flutter_map with school markers color-coded by priority
  ├── ValidationTab    — Tabbed (Pending/Flagged/Approved/Rejected), AI validate + manual approve/flag/reject
  └── AnalyticsTab     — Charts (currently hardcoded demo data)
```

## Validation Tab UI
- Cards show AI vs Officer validation with distinct icons (robot vs person)
- Relative timestamps ("2d ago", "5h ago")
- Tab bar shows counts: "Pending (43)"
- Manual validation requires `canValidate` permission
- Confirmation dialog shows "Will be recorded as: [Officer Name]"
- AI validation has 30-second timeout to prevent infinite loading

## Known Issues / Dead Code
- `analytics_tab.dart`: 100% hardcoded demo data, ignores providers
- `ApiService`: Never imported from UI — ML backend unreachable without manual start
- `ExcelExportService` / `PdfExportService`: Export buttons exist but services may error
- `InspectionScreen`: Orphaned — navigation exists only from school profile AppBar
- `si_users` table: Empty. App uses in-memory demo users via `setDemoUser(role)`

## PostgreSQL Notes
- `CREATE POLICY IF NOT EXISTS` is NOT valid syntax — use `DROP POLICY IF EXISTS ... ; CREATE POLICY ...`
- Supabase `.in_()` limited to ~500 items — getScopedPriorityScores fetches all and filters in Dart

## Build & Run
```bash
# Flutter app
cd school_infra_app && flutter pub get && flutter run

# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Python backend (optional)
./start_backend.sh
# API docs: http://localhost:8000/docs
```
