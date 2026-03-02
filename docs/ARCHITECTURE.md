# Architecture — Vidya Soudha

## System Architecture

```
+---------------------+         +------------------+        +----------------+
|   Flutter Mobile    |  HTTPS  |    Supabase      |        |  FastAPI ML    |
|   App (Client)      |<------->|  (PostgreSQL +   |        |  Backend       |
|                     |         |   Auth + RLS)    |        |  (Python)      |
|  - Riverpod State   |         |                  |        |                |
|  - fl_chart         |   HTTP  |  si_schools      |        | /api/forecast  |
|  - flutter_map      |<------->|  si_demands      |<------>| /api/validate  |
|  - Hive Cache       |         |  si_enrolment    |        | /api/analytics |
+---------------------+         +------------------+        +----------------+
         |                                                          |
         |  Offline Fallback                                        |
         +---> Hive Local Cache                                     |
         +---> Client-side ML (linear extrapolation)                |
                                                                    |
                                                    scikit-learn models:
                                                    - Isolation Forest
                                                    - Linear Regression
```

## Architecture Principles

### 1. Offline-First Design
The app is designed to work without network connectivity:
- **Primary**: Supabase cloud database (when online)
- **Fallback 1**: Hive local cache (when network unavailable)
- **Fallback 2**: Client-side ML models (when backend unreachable)
- **Sync Queue**: Field assessments queued locally, synced when reconnected

### 2. Role-Based Data Scoping
Data access is enforced at multiple levels:
- **Database**: Supabase Row-Level Security (RLS) policies
- **Application**: Riverpod providers scope data based on user role
- **UI**: Tabs and actions conditionally rendered per role permissions

### 3. ML Backend as Enhancement, Not Dependency
- The app is fully functional without the Python backend
- Backend adds: Isolation Forest anomaly detection, Linear Regression forecasting
- Client-side provides: Rule-based validation, Linear extrapolation
- Backend status indicator (green/orange dot) shows current mode

---

## Component Diagram

### Flutter App Components

```
lib/
  config/
    api_config.dart          # Supabase URL, API endpoints, colors, constants

  models/                    # Pure Dart data classes
    school.dart              # School with fromJson/toJson
    demand_plan.dart         # DemandPlan with validation status
    enrolment.dart           # EnrolmentRecord + EnrolmentTrend
    priority_score.dart      # SchoolPriorityScore (4-factor composite)
    user.dart                # AppUser with role permissions
    infra_assessment.dart    # Field inspection data

  services/                  # Business logic (no UI)
    supabase_service.dart    # Supabase CRUD operations
    api_service.dart         # FastAPI ML backend client (Dio)
    demand_validation_service.dart  # 7-rule validation engine
    priority_scoring_service.dart   # 4-factor priority scoring
    export_service.dart      # Orchestrator for exports
    excel_export_service.dart # 3-sheet Excel generation
    pdf_export_service.dart   # School report PDF
    offline_cache_service.dart # Hive-based local caching

  providers/                 # Riverpod state management
    auth_provider.dart       # CurrentUser + demo role selection
    schools_provider.dart    # Schools list + filters (role-scoped)
    dashboard_provider.dart  # Stats, validation, forecast, priority
    locale_provider.dart     # EN/TE language toggle

  screens/                   # UI layer
    auth/role_selection_screen.dart
    dashboard/
      dashboard_screen.dart  # AppBar + BottomNav + tab routing
      tabs/
        overview_tab.dart    # Stats cards + priority pie + demand summary
        schools_tab.dart     # Filterable school list
        map_tab.dart         # flutter_map + marker clustering
        validation_tab.dart  # AI/Officer validation workflow
        analytics_tab.dart   # 9 analytics sections
    schools/
      school_profile_screen.dart  # Detail view with forecast, budget, inspection
    inspection/
      inspection_screen.dart     # Field assessment form

  l10n/
    app_localizations.dart   # 280+ keys in EN + TE
```

### Backend Components

```
school-infra-backend/
  app/
    main.py                  # FastAPI app + CORS + router registration
    api/
      forecast.py            # POST /api/forecast/enrolment/{id}
      validate.py            # POST /api/validate/demand-plan
      analytics.py           # GET /api/analytics/state, district
    services/
      forecast_service.py    # Linear Regression + Cohort Progression
      validation_service.py  # Rule-based + Isolation Forest
      db.py                  # Supabase client (Python)
    models/
      schemas.py             # Pydantic request/response models
```

---

## Data Flow

### 1. App Startup Flow
```
RoleSelectionScreen
  -> User selects role (e.g., STATE_OFFICIAL)
  -> AuthProvider.setDemoUser(role)
     -> Fetches real district/mandal/school IDs from Supabase
     -> Creates AppUser with permissions
  -> Navigate to DashboardScreen
     -> Auto-compute priority scores if table empty
     -> Check backend health (/health endpoint)
     -> Load 5 tabs based on role permissions
```

### 2. Validation Flow
```
Officer taps "AI Validate" on a demand plan
  -> DashboardProvider.validateDemand(planId)
  -> Try: ApiService.validateDemandPlans([plan])  // Backend
     -> Backend runs Isolation Forest + Rule-based checks
     -> Returns anomaly_score, is_anomaly, reasons
  -> Catch: DemandValidationService.validateSingle(plan)  // Client
     -> Runs 7 rules locally
     -> Returns score (0-100) + flags + per-rule breakdown
  -> Update UI with result + XAI breakdown
```

### 3. Forecast Flow
```
User taps "Forecast" on school profile
  -> ForecastNotifier.forecastSchool(schoolId)
  -> Try: ApiService.forecastEnrolment(id, yearsAhead: 3)
     -> Backend: Linear Regression on historical enrolment
     -> Returns forecasts with model_used: "LinearRegression"
  -> Catch: Client-side fallback
     -> Fetch enrolment history from Supabase
     -> Compute growth rate from EnrolmentTrend
     -> Project 3 years with declining confidence
     -> Tag model: "client_linear"
  -> UI shows trend, growth rate, chart, confidence bands
```

### 4. Offline Flow
```
No network available:
  -> SchoolsProvider catches SupabaseException
  -> Falls back to OfflineCacheService.getCachedSchools()
  -> Shows cached data with offline banner

Field inspector submits assessment offline:
  -> InspectionScreen.submitAssessment()
  -> Try: SupabaseService.upsertAssessment()
  -> Catch: OfflineCacheService.queueAssessment()
  -> Dashboard shows "N assessment(s) pending sync" banner
  -> Tap "Sync Now" -> processes queue when online
```

---

## State Management (Riverpod 3.x)

### Provider Architecture

| Provider | Type | Scope | Purpose |
|----------|------|-------|---------|
| `currentUserProvider` | Notifier | Global | Active user + role |
| `schoolsProvider` | FutureProvider | Role-scoped | Schools list |
| `demandPlansProvider` | FutureProvider | Role-scoped | Demand plans |
| `dashboardStatsProvider` | FutureProvider | Role-scoped | Overview counts |
| `priorityScoresProvider` | FutureProvider | Global | All priority scores |
| `forecastProvider` | Notifier | Per-action | Enrolment forecast |
| `validateDemandProvider` | Notifier | Per-action | Validation result |
| `localeProvider` | Notifier | Global | EN/TE toggle |

### Role-Scoped Providers
```dart
effectiveDistrictProvider  // Locks non-state roles to their district
effectiveMandalProvider    // Locks block/field/HM to their mandal
effectiveSchoolIdProvider  // Locks HM to their single school
```

These providers cascade: when `currentUserProvider` changes role, all downstream providers automatically refetch with the new scope.

---

## Security Architecture

### Database Security (Supabase RLS)
- All `si_*` tables have Row-Level Security enabled
- Policies restrict read/write based on user role stored in JWT
- Anon key used for demo mode (read-only access)

### API Security
- FastAPI backend uses CORS middleware (allow all origins for demo)
- Supabase anon key stored in app config (not in source control for production)
- No PII stored — only aggregate education data

### Client Security
- No passwords stored (demo role selection)
- Hive cache stores only school/demand data (no credentials)
- Export files saved to app-private directory
