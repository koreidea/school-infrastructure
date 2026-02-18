# Bal Vikas ECD Platform — Scalability Architecture

## Executive Summary

The Bal Vikas ECD platform is architected for **progressive scalability** from a pilot of 10 AWCs / 200 children to national deployment across 13.7 lakh AWCs and 8+ crore children. The system uses an offline-first architecture with background sync, hierarchical role-based dashboards, and configurable screening tools — all designed to operate reliably in low-connectivity rural environments.

---

## Current Pilot Scope

| Metric | Value |
|--------|-------|
| AWC Centres | 10 |
| Children | 200 |
| Screening Tools | 14 |
| Roles Supported | 7 (AWW, Supervisor, CDPO, CW, EO, DW, Senior Official) |
| Languages | 2 (English, Telugu) |

---

## Scalability Dimensions

### 1. Data Architecture — Offline-First with Sync

**Pattern:** Drift (SQLite) local cache → Background Supabase sync → Conflict-free upsert

- **Offline Capability:** All screening, child registration, and result viewing works without internet connectivity. AWWs in remote areas can conduct full assessments offline.
- **Sync Queue:** Priority-ordered queue (session → responses → results) ensures data integrity during intermittent connectivity.
- **Conflict Resolution:** Last-write-wins with server timestamps. Sync queue retries failed items automatically on reconnection.
- **Scale Impact:** Each device operates independently. No real-time server dependency. Supabase backend scales horizontally with Postgres connection pooling.

```
┌──────────────┐     Background Sync     ┌──────────────────┐
│  Drift SQLite │  ◄──────────────────►   │  Supabase Cloud  │
│  (per device) │     when connected      │  (Postgres + RLS)│
└──────────────┘                          └──────────────────┘
```

### 2. Hierarchical Dashboard Architecture

**Pattern:** Scoped providers with drill-down navigation

```
State Dashboard (Senior Official)
  └─► District Dashboard (DW)
        └─► Project Dashboard (CDPO/CW/EO)
              └─► Sector Dashboard (Supervisor)
                    └─► AWC Dashboard (AWW)
                          └─► Child Profile
```

- **Aggregation:** Stats computed at each level (total children, screened count, high-risk, referrals).
- **Sub-unit Cards:** Each level shows performance of subordinate units with drill-down navigation.
- **Scale Impact:** Adding new states/districts/projects requires only data insertion, not code changes. The UI dynamically renders based on the ICDS hierarchy tree.

### 3. Screening Tool Framework — Extensible Plugin Architecture

**Pattern:** Enum-driven tool registry with configurable scoring

```dart
ScreeningToolType → ScreeningToolConfig → ScreeningQuestion[]
                                        → ResponseFormat
                                        → ToolScorer (scoring rules)
```

- **Current Tools (14):** CDC Milestones, RBSK, M-CHAT, ISAA, ADHD, RBSK Behavioral, SDQ, Parent-Child Interaction, PHQ-9, Home Stimulation, Nutrition, Home Environment, Birth Defects, Disease Screening.
- **Adding a New Tool:** 3 files (tool data, enum entry, scorer) — no UI changes needed.
- **Configurable Scoring:** Thresholds stored as rules that can be overridden from Supabase `scoring_rules` table without app updates.
- **Age-Filtered:** Tools automatically appear/disappear based on child's age bracket.

### 4. Multi-Language Architecture

**Pattern:** Inline bilingual fields with runtime toggle

- Every text element has `_te` (Telugu) variant alongside English.
- `languageProvider` toggles UI instantly without restart.
- **Adding a New Language:** Add `_hi` (Hindi), `_kn` (Kannada), etc. fields to existing data structures. Provider pattern supports N languages.
- Transliteration utility (`toTelugu()`) handles name display.

### 5. Role-Based Access Control

**Pattern:** Supabase RLS + Client-side role routing

| Role | Scope | Access Level |
|------|-------|-------------|
| AWW | Single AWC | Register children, conduct screenings, view activities |
| Supervisor | Sector (multiple AWCs) | Monitor AWC performance, review high-risk cases |
| CDPO/CW/EO | Project (multiple sectors) | Project-level analytics, sector comparison |
| DW | District (multiple projects) | District overview, project-level drill-down |
| Senior Official | State (multiple districts) | State-wide analytics, policy-level insights |

- **Row Level Security:** Supabase RLS policies ensure users only access data within their jurisdiction.
- **Scale Impact:** New roles can be added without schema changes. Role routing is switch-based with fallback.

---

## Scaling Projections

### Phase 1 — Pilot (Current)
- 1 State, 1 District, 1 Project, 2 Sectors, 10 AWCs
- 200 children, ~20 concurrent users
- Single Supabase instance (free tier sufficient)

### Phase 2 — District Scale
- 1 State, 1 District, 5 Projects, 25 Sectors, 150 AWCs
- 3,000 children, ~200 concurrent users
- Supabase Pro plan, connection pooling enabled

### Phase 3 — State Scale
- 1 State, 13 Districts, 65 Projects, 325 Sectors, 3,250 AWCs
- 65,000 children, ~4,000 concurrent users
- Supabase with read replicas, CDN for static assets

### Phase 4 — Multi-State / National
- 36 States, 730 Districts, 7,000+ Projects
- 13.7 lakh AWCs, 8+ crore children
- Distributed Supabase clusters per state/region
- Regional sync servers for reduced latency
- Data warehouse for national-level analytics

---

## Technical Scaling Strategies

### Database
- **Partitioning:** Children table partitioned by state_id for query performance.
- **Indexing:** Compound indexes on (awc_id, assessment_date) for common dashboard queries.
- **Read Replicas:** Dashboard queries routed to read replicas; writes to primary.
- **Archival:** Historical screening data (>2 years) moved to cold storage with summary retention.

### API / Backend
- **Connection Pooling:** PgBouncer for Supabase connection management.
- **Caching:** Redis cache for aggregated dashboard stats (TTL: 5 minutes).
- **Rate Limiting:** Per-role API rate limits to prevent abuse.
- **Edge Functions:** Supabase Edge Functions for complex aggregation without client-side computation.

### Mobile App
- **Lazy Loading:** Children list paginated (50 per page). Dashboard stats loaded on-demand per scope.
- **Selective Sync:** Only sync children and results within user's jurisdiction, not entire database.
- **Background Sync:** Sync queue processes in background isolate, doesn't block UI.
- **Data Pruning:** Local SQLite periodically prunes synced records older than 6 months.

### Monitoring
- **Sync Health:** Dashboard showing sync queue depth, failure rate, last sync time per AWC.
- **Coverage Tracking:** Real-time screening coverage percentage at every hierarchy level.
- **Alert System:** Automated alerts for AWCs with <50% monthly coverage or >72-hour sync gaps.

---

## Infrastructure Cost Estimates

| Scale | Users | Storage | Monthly Cost (Est.) |
|-------|-------|---------|-------------------|
| Pilot (10 AWCs) | 20 | <1 GB | Free tier |
| District (150 AWCs) | 200 | ~5 GB | ~$25/month |
| State (3,250 AWCs) | 4,000 | ~100 GB | ~$200/month |
| National (13.7L AWCs) | 500,000+ | ~10 TB | ~$5,000/month |

*Costs assume Supabase pricing. Self-hosted Postgres reduces costs further at national scale.*

---

## Key Design Decisions for Scale

1. **Offline-First:** Critical for rural India where 40%+ AWCs have intermittent connectivity.
2. **Hierarchical Aggregation:** Each dashboard level computes its own stats, avoiding N+1 queries.
3. **Configurable Scoring:** Thresholds adjustable without app updates — essential for policy changes.
4. **Bilingual by Default:** Every string has language variants, making expansion to 22 scheduled languages feasible.
5. **Role-Scoped Data:** Users only download/sync data within their jurisdiction, keeping local DB manageable.
6. **Extensible Tools:** New screening tools (e.g., vision, hearing) can be added in hours, not weeks.
