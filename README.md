# Vidya Soudha (విద్యా సౌధ) — School Infrastructure Planning & Monitoring

An **AI-powered** school infrastructure planning and monitoring platform for the **Department of School Education, Andhra Pradesh**.

Built for **Problem Statement 5** of the **IndiaAI Innovation Challenge for Transforming Governance**.

## Key Features

- **AI Demand Validation** — Rule-based validation of infrastructure demand plans against Samagra Shiksha norms (cost anomalies, duplicates, peer outliers)
- **Priority Scoring** — Composite scoring (0–100) across enrolment pressure, infrastructure gaps, CWSN needs, and accessibility
- **Enrolment Forecasting** — Linear trend extrapolation with confidence intervals for 3-year projections
- **Role-Based Access** — 5 roles: State Official, District Officer, Block Officer, Field Inspector, School HM
- **Interactive Map** — Geospatial view of all schools with priority color-coding
- **Bilingual** — English + Telugu (తెలుగు) localization
- **Offline Support** — Hive-based local caching for field use
- **Export** — PDF and Excel export of school data and demand plans

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.10+ with Riverpod 3.x |
| Backend | FastAPI (Python) — ML forecasting |
| Database | Supabase (PostgreSQL + Auth + RLS) |
| Charts | fl_chart |
| Maps | flutter_map (OpenStreetMap) |
| Export | syncfusion_flutter_xlsio, pdf |

## Project Structure

```
school_infra_app/     # Flutter app (main codebase)
school-infra-backend/ # Python FastAPI ML backend
start_backend.sh      # Backend launcher script
Reference/            # Sample data files from IndiaAI
```

## Quick Start

```bash
# Run the Flutter app
cd school_infra_app
flutter pub get
flutter run

# Run the Python backend (optional — app works without it)
./start_backend.sh
```

## Supabase Tables

All tables use `si_` prefix: `si_schools`, `si_districts`, `si_mandals`, `si_demand_plans`, `si_enrolment_records`, `si_school_priority_scores`, `si_infra_assessments`, `si_users`.

## Data

- 1 State (Andhra Pradesh), 57 Districts, 707 Mandals
- 319 Schools with enrolment history
- 799 Infrastructure demand plans
- 4,638 Enrolment records across multiple academic years
