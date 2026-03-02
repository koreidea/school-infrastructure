# Vidya Soudha (విద్యా సౌధ)

**AI-Powered School Infrastructure Planning & Monitoring Platform**

Built for **Problem Statement 5** of the **IndiaAI Innovation Challenge for Transforming Governance** — Department of School Education, Andhra Pradesh.

---

## Overview

Vidya Soudha is a comprehensive mobile application that leverages artificial intelligence to optimize school infrastructure planning, validate demand proposals, and enable data-driven decision-making across the education administrative hierarchy of Andhra Pradesh.

### Problem Statement
> Design an AI-powered tool that assists the Department of School Education in planning, monitoring, and optimizing school infrastructure investments across districts using real-time data analysis, demand forecasting, and intelligent resource allocation.

### Our Solution
A Flutter-based mobile app with a FastAPI ML backend that provides:
- Real-time AI validation of infrastructure demand proposals
- Predictive enrolment forecasting using linear regression
- Composite priority scoring for equitable resource distribution
- Role-based dashboards for 5 levels of administrative hierarchy
- Offline-capable field inspection workflow
- Bilingual support (English + Telugu)

---

## Key Features

### 1. AI-Powered Demand Validation
- **7-rule validation engine** checks demand proposals against Samagra Shiksha norms
- Rules: Unit Cost Deviation, Duplicate Detection, Enrolment Correlation, Peer Comparison, Zero-Value Check, Existing Infrastructure, Over-Reporting
- **Isolation Forest ML** anomaly detection (when backend is online)
- Per-rule explainability (XAI) showing pass/fail for each check with reasoning

### 2. Composite Priority Scoring
- 4-factor weighted scoring (0-100): Enrolment Pressure (30%), Infrastructure Gap (30%), CWSN Needs (20%), Accessibility (20%)
- Priority levels: CRITICAL (>80), HIGH (>60), MEDIUM (>40), LOW (<=40)
- Auto-computed for all 319 schools on first dashboard load

### 3. Enrolment Forecasting
- **Backend**: Linear Regression + Cohort Progression (Python/scikit-learn)
- **Client-side fallback**: Linear extrapolation with declining confidence bands
- 3-year projections with confidence intervals (95% -> 75% -> 55%)

### 4. Budget Allocation Planner
- 3 strategies: Conservative (60%), Balanced (100%), Growth-Oriented (130%+)
- Per-infrastructure-type cost breakdown
- Integrated with enrolment forecast growth projections

### 5. Interactive School Map
- OpenStreetMap-based visualization of all 319 schools
- Priority-based color coding (red/orange/yellow/green)
- Grid-based clustering at low zoom levels
- Tap-to-view school details with priority score

### 6. Role-Based Access Control

| Role | Data Scope | Can Validate | Can Inspect |
|------|-----------|-------------|-------------|
| State Education Director | All schools statewide | Yes | No |
| District Education Officer | Own district only | Yes | No |
| Mandal Education Officer | Own mandal only | Yes | Yes |
| Field Inspector | Own mandal only | No | Yes |
| Head Master | Own school only | No | No |

### 7. Field Inspection Workflow
- Structured assessment form (classrooms, toilets, CWSN facilities, amenities)
- Photo evidence capture (camera + gallery)
- Condition rating with repair/maintenance cost estimation
- Offline queue with sync-when-connected capability

### 8. Export & Reporting
- **Excel export**: 3-sheet workbook (School Registry, Demand Plans, Priority Scores)
- **PDF export**: Individual school report cards with enrolment history and demand details

### 9. Bilingual Localization
- Complete English and Telugu (తెలుగు) support with 280+ translation keys
- One-tap language toggle in the app bar

### 10. Offline-First Architecture
- Hive-based local caching for schools, demands, and assessments
- Sync queue banner showing pending uploads
- Graceful degradation: ML backend -> client-side fallback -> cached data

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile App** | Flutter 3.10+ | Cross-platform UI |
| **State Management** | Riverpod 3.x | Reactive state with role-scoped providers |
| **Backend** | FastAPI (Python) | ML inference endpoints |
| **Database** | Supabase (PostgreSQL) | Cloud DB with RLS + Auth |
| **ML Models** | scikit-learn | Isolation Forest, Linear Regression |
| **Charts** | fl_chart | Bar, line, pie charts |
| **Maps** | flutter_map | OpenStreetMap tiles |
| **Local Cache** | Hive | Offline data persistence |
| **Export** | openpyxl, pdf | Excel and PDF generation |

---

## Project Structure

```
school infrastructure/
  school_infra_app/              # Flutter mobile app
    lib/
      config/api_config.dart       # Constants, colors, Supabase config
      models/                      # Data models (School, DemandPlan, etc.)
      services/                    # Business logic & API clients
      providers/                   # Riverpod state providers
      screens/                     # UI screens & tabs
      l10n/                        # Localization (EN + TE)
  school-infra-backend/            # Python FastAPI ML backend
    app/
      main.py                      # FastAPI app entry
      api/                         # Route handlers
      services/                    # ML model services
      models/                      # Pydantic schemas
  notebooks/                       # Jupyter ML analysis notebook
    model_analysis.ipynb           # Model evaluation + 16 charts
  Reference/                       # IndiaAI sample data (Excel)
  docs/                            # Project documentation
  start_backend.sh                 # Backend launcher script
```

---

## Quick Start

### Prerequisites
- Flutter SDK 3.10+
- Python 3.8+ (for ML backend)
- Android Studio / Xcode (for emulator)

### Run the Flutter App
```bash
cd school_infra_app
flutter pub get
flutter run
```

### Run the ML Backend (Optional)
```bash
./start_backend.sh
# API docs: http://localhost:8000/docs
# Health: http://localhost:8000/health
```

### Build Release APK
```bash
cd school_infra_app
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Data Summary

| Entity | Count | Source |
|--------|-------|--------|
| State | 1 (Andhra Pradesh) | IndiaAI dataset |
| Districts | 57 | si_districts |
| Mandals | 707 | si_mandals |
| Schools | 319 | si_schools |
| Demand Plans | 799 | si_demand_plans |
| Enrolment Records | 4,638 | si_enrolment_records |
| Infrastructure Types | 5 | CWSN Room, CWSN Toilet, Water, Electric, Ramps |

---

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](./docs/ARCHITECTURE.md) | System design, component diagram, data flow |
| [DATABASE.md](./docs/DATABASE.md) | Schema, tables, RLS policies, relationships |
| [AI_FEATURES.md](./docs/AI_FEATURES.md) | ML models, validation rules, scoring algorithms |
| [API.md](./docs/API.md) | Backend API endpoints, request/response formats |
| [DEPLOYMENT.md](./docs/DEPLOYMENT.md) | Build, run, deploy instructions |

---

## Screenshots

The app includes 5 dashboard tabs visible based on user role:
1. **Overview** — Stats cards, priority distribution pie chart, demand summary
2. **Schools** — Searchable/filterable school list with priority badges
3. **Map** — Interactive OpenStreetMap with clustered school markers
4. **Validation** — AI + Officer validation workflow with XAI breakdown
5. **Analytics** — 9 analytics sections with real-time charts and metrics

---

## License

Built for the IndiaAI Innovation Challenge. All rights reserved.

## Team

Vidya Soudha Team — IndiaAI Problem Statement 5
