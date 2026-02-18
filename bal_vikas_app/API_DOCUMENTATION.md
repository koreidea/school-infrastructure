# Bal Vikas ECD Platform — API Documentation

## Overview

The Bal Vikas ECD (Early Childhood Development) platform uses a **dual API architecture**:

1. **Supabase API** (Primary) — PostgreSQL-backed BaaS with Row-Level Security (RLS), real-time subscriptions, and RPC functions
2. **REST API** (Secondary) — FastAPI backend for specialized operations (OTP, Excel export, ML recommendations)

Both APIs support the ICDS hierarchy: **State → District → Project → Sector → AWC → Child**

---

## Authentication

### Supabase Auth
- **Method:** Email/Password (pilot mode) → OTP-based (production)
- **Token:** JWT issued by Supabase Auth, auto-refreshed via SDK
- **RPC Bootstrap:** `get_my_profile` — returns user profile bypassing RLS on first fetch
- **Link Flow:** After auth, `link_auth_uid(phone_number)` maps Supabase auth UID to `users` table

### REST API Auth
- **Method:** Bearer token in `Authorization` header
- **Token Source:** `/api/auth/verify-otp` returns JWT token
- **Refresh:** Automatic via Dio interceptor — refreshes on 401

### Auth Flow (Pilot)
```
1. User enters phone number
2. RPC: check_phone_exists(phone) → validates user exists
3. Supabase signInWithPassword(email: "{phone}@balvikas.pilot", password: "pilot123456")
4. If new user → signUp → link_auth_uid(phone)
5. RPC: get_my_profile → full User object with role/hierarchy
6. Background: pullScreeningConfigs() + pullChildren()
```

---

## Data Models

### User
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Supabase user ID |
| phone | String | 10-digit mobile number |
| name | String | Full name |
| role | String | Role code (AWW, SUPERVISOR, CDPO, CW, EO, DW, SENIOR_OFFICIAL, PARENT, ADMIN) |
| awc_id | Int? | Assigned AWC (AWW only) |
| sector_id | Int? | Assigned sector (Supervisor only) |
| project_id | Int? | Assigned project (CDPO/CW/EO) |
| district_id | Int? | Assigned district (DW) |
| state_id | Int? | Assigned state (Senior Official) |
| preferred_language | String | 'en' or 'te' |
| is_active | Bool | Account active status |

### Child
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Auto-increment ID |
| child_unique_id | String | Unique identifier (e.g., "BV-001") |
| name | String | Child's full name |
| dob | Date | Date of birth (YYYY-MM-DD) |
| gender | String | 'male' or 'female' |
| parent_id | Int? | Foreign key → users.id |
| awc_id | Int | Foreign key → anganwadi_centres.id |
| is_active | Bool | Active status |
| created_at | Timestamp | Registration timestamp |

### Screening Session
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Auto-increment ID |
| child_id | Int | Foreign key → children.id |
| conducted_by | UUID | Supabase auth user ID |
| assessment_date | Date | Date of screening |
| child_age_months | Int | Child's age at screening |
| status | String | 'in_progress' or 'completed' |
| device_session_id | String? | Local Drift session ID for sync mapping |
| completed_at | Timestamp? | Completion timestamp |

### Screening Response
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Auto-increment ID |
| session_id | Int | Foreign key → screening_sessions.id |
| tool_type | String | Screening tool identifier (e.g., 'cdcMilestones') |
| question_id | String | Question identifier |
| response_value | Dynamic | Answer value (varies by response format) |

### Screening Result
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Auto-increment ID |
| session_id | Int | Foreign key → screening_sessions.id |
| child_id | Int | Foreign key → children.id |
| overall_risk | String | 'LOW', 'MEDIUM', 'MEDIUM-HIGH', 'HIGH' |
| overall_risk_te | String? | Telugu translation of risk level |
| referral_needed | Bool | Whether referral is triggered |
| gm_dq | Float? | Gross Motor developmental quotient |
| fm_dq | Float? | Fine Motor developmental quotient |
| lc_dq | Float? | Language developmental quotient |
| cog_dq | Float? | Cognitive developmental quotient |
| se_dq | Float? | Social-Emotional developmental quotient |
| composite_dq | Float? | Overall composite DQ score |
| tool_results | JSONB | Per-tool scoring results |
| concerns | Text[] | English concern descriptions |
| concerns_te | Text[] | Telugu concern descriptions |
| tools_completed | Int | Number of tools completed |
| tools_skipped | Int | Number of tools skipped |

### Referral
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Auto-increment ID |
| child_id | Int | Foreign key → children.id |
| screening_result_id | Int? | Foreign key → screening_results.id |
| referral_triggered | Bool | Whether auto-triggered |
| referral_type | String | 'DEIC', 'RBSK', 'PHC', 'AWW_INTERVENTION' |
| referral_reason | String | 'AUTISM', 'ADHD', 'GDD', 'BEHAVIOUR', 'DOMAIN_DELAY', 'ENVIRONMENT' |
| referral_status | String | 'Pending', 'In Progress', 'Completed' |
| referred_by_user_id | UUID? | User who created referral |
| referred_date | Date? | Referral date |
| completed_date | Date? | Completion date |
| notes | Text? | Additional notes |

### Nutrition Assessment
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Auto-increment ID |
| child_id | Int | Foreign key → children.id |
| session_id | Int? | Foreign key → screening_sessions.id |
| height_cm | Float? | Height in centimeters |
| weight_kg | Float? | Weight in kilograms |
| muac_cm | Float? | Mid-upper arm circumference |
| underweight | Bool | Underweight flag |
| stunting | Bool | Stunting flag |
| wasting | Bool | Wasting flag |
| anemia | Bool | Anemia flag |
| nutrition_score | Int | Composite nutrition score |
| nutrition_risk | String | 'LOW', 'MEDIUM', 'HIGH' |

### Environment Assessment
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Auto-increment ID |
| child_id | Int | Foreign key → children.id |
| session_id | Int? | Foreign key → screening_sessions.id |
| parent_child_interaction_score | Int? | Interaction quality (0-10) |
| parent_mental_health_score | Int? | PHQ-9 derived score |
| home_stimulation_score | Int? | Home stimulation index |
| play_materials | Bool | Adequate play materials |
| caregiver_engagement | String | 'LOW', 'MODERATE', 'HIGH' |
| language_exposure | String | 'LIMITED', 'ADEQUATE', 'RICH' |
| safe_water | Bool | Access to safe water |
| toilet_facility | Bool | Access to toilet facility |

### Intervention Follow-up
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Auto-increment ID |
| child_id | Int | Foreign key → children.id |
| screening_result_id | Int? | Foreign key → screening_results.id |
| followup_conducted | Bool | Whether follow-up was done |
| followup_date | Date? | Follow-up date |
| improvement_status | String? | 'Improving', 'Stable', 'Worsening' |
| reduction_in_delay_months | Int | Months of delay reduction |
| domain_improvement | Bool | Whether domain improvement seen |
| exit_high_risk | Bool | Whether child exited high-risk |
| notes | Text? | Follow-up notes |

---

## ICDS Hierarchy Tables

### States
| Field | Type | Description |
|-------|------|-------------|
| id | Int | State ID |
| name | String | State name |
| code | String | State code |

### Districts
| Field | Type | Description |
|-------|------|-------------|
| id | Int | District ID |
| state_id | Int | FK → states.id |
| name | String | District name |

### Projects
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Project ID |
| district_id | Int | FK → districts.id |
| name | String | Project name |

### Sectors
| Field | Type | Description |
|-------|------|-------------|
| id | Int | Sector ID |
| project_id | Int | FK → projects.id |
| name | String | Sector name |

### Anganwadi Centres (AWCs)
| Field | Type | Description |
|-------|------|-------------|
| id | Int | AWC ID |
| sector_id | Int | FK → sectors.id |
| centre_code | String | Unique centre code |
| name | String | Centre name |
| is_active | Bool | Active status |

---

## Supabase API Endpoints

### RPC Functions

| Function | Params | Returns | Description |
|----------|--------|---------|-------------|
| `get_my_profile` | None | User JSON | Get authenticated user's profile (bypasses RLS) |
| `check_phone_exists` | phone: String | Bool | Check if phone number exists in users table |
| `link_auth_uid` | phone_number: String | Void | Link Supabase auth UID to users table |
| `get_dashboard_stats` | p_scope: String, p_scope_id: Int | Stats JSON | Aggregate stats for dashboard (by scope level) |

### Table Operations (PostgREST)

#### Children
```
GET    /rest/v1/children?awc_id=eq.{awcId}&is_active=eq.true&order=name
POST   /rest/v1/children                     → Insert child record
PATCH  /rest/v1/children?id=eq.{id}          → Update child record
```

#### Screening Sessions
```
POST   /rest/v1/screening_sessions           → Create new session
PATCH  /rest/v1/screening_sessions?id=eq.{id} → Update session status
```

#### Screening Responses
```
POST   /rest/v1/screening_responses          → Batch insert responses
```

#### Screening Results
```
POST   /rest/v1/screening_results            → Insert result
GET    /rest/v1/screening_results?child_id=eq.{id}&order=created_at.desc
                                              → Get screening history
GET    /rest/v1/screening_results?child_id=in.({ids})&select=*,screening_sessions!inner(*),children!inner(*)
                                              → Batch results with joins
```

#### Referrals
```
POST   /rest/v1/referrals                    → Create referral
GET    /rest/v1/referrals?child_id=eq.{id}   → Get child's referrals
```

#### Nutrition Assessments
```
POST   /rest/v1/nutrition_assessments        → Save nutrition data
GET    /rest/v1/nutrition_assessments?child_id=eq.{id}
```

#### Environment Assessments
```
POST   /rest/v1/environment_assessments      → Save environment data
GET    /rest/v1/environment_assessments?child_id=eq.{id}
```

#### Intervention Follow-ups
```
POST   /rest/v1/intervention_followups       → Save follow-up
GET    /rest/v1/intervention_followups?child_id=eq.{id}
```

#### ICDS Hierarchy
```
GET    /rest/v1/anganwadi_centres?sector_id=eq.{id}&is_active=eq.true
GET    /rest/v1/sectors?project_id=eq.{id}
GET    /rest/v1/projects?district_id=eq.{id}
GET    /rest/v1/districts?state_id=eq.{id}
```

---

## REST API Endpoints

### Authentication
| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/api/auth/send-otp` | `{ "mobile_number": "9876543210" }` | `{ "success": true }` |
| POST | `/api/auth/verify-otp` | `{ "mobile_number": "...", "otp": "1234" }` | `{ "token": "jwt...", "user": {...} }` |
| GET | `/api/auth/profile` | — | User profile JSON |
| PUT | `/api/auth/update-role` | `{ "role_code": "AWW" }` | Updated profile |
| PUT | `/api/auth/profile` | `{ "name": "..." }` (multipart) | Updated profile |

### Children
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/children` | List accessible children (role-filtered) |
| GET | `/api/children/{id}` | Get child details with stats |
| POST | `/api/children` | Create new child record |

### Screening
| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| POST | `/api/screening/start` | `{ "child_id": 1, ... }` | Start screening session |
| POST | `/api/screening/{sessionId}/responses` | `{ "tool_type": "...", "responses": {...} }` | Save tool responses |
| POST | `/api/screening/{sessionId}/complete` | `{ "measurements": {...} }` | Complete session |
| GET | `/api/screening/{sessionId}` | — | Get session details |
| GET | `/api/screening/child/{childId}` | — | List child's screenings |

### Export
| Method | Endpoint | Response | Description |
|--------|----------|----------|-------------|
| POST | `/api/export/child/{childId}/excel` | Binary (xlsx) | Download child report as Excel |

### Interventions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/interventions/activities` | List all intervention activities |
| GET | `/api/interventions/recommend/{childId}` | Get AI-recommended activities |

### Questionnaires
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/questionnaires/latest` | Get latest screening config |

---

## Offline-First Sync Architecture

### Local Database (Drift/SQLite)
The app maintains a complete local SQLite database using Drift ORM for offline operation:

```
┌──────────────────────┐          ┌──────────────────────────┐
│   Drift SQLite       │  Sync    │   Supabase PostgreSQL    │
│   (per device)       │ ◄──────► │   (cloud)                │
│                      │          │                          │
│ LocalChildren        │          │ children                 │
│ LocalScreeningSessions│         │ screening_sessions       │
│ LocalScreeningResponses│        │ screening_responses      │
│ LocalScreeningResults│          │ screening_results        │
│ LocalReferrals       │          │ referrals                │
│ LocalNutritionAssessments│      │ nutrition_assessments    │
│ LocalEnvironmentAssessments│    │ environment_assessments  │
│ LocalInterventionFollowups│     │ intervention_followups   │
│ SyncQueue            │          │ (sync tracking)          │
└──────────────────────┘          └──────────────────────────┘
```

### Sync Queue
| Field | Description |
|-------|-------------|
| entityType | 'session', 'responses', 'result', 'referral', 'nutrition', 'environment', 'followup' |
| entityLocalId | Local Drift row ID |
| operation | 'insert', 'update', 'delete' |
| priority | 0 (session) → 1 (responses) → 2 (result) → 3 (others) |
| status | 'pending', 'syncing', 'synced', 'error' |
| retryCount | Number of retry attempts |
| lastError | Last error message |

### Sync Flow
```
1. User creates data → saved to Drift immediately → UI updates instantly
2. SyncQueue entry created (priority-ordered)
3. ConnectivityService detects online status
4. SyncService processes queue: session(0) → responses(1) → result(2) → others(3)
5. On success: maps localId → remoteId, marks as synced
6. On failure: increments retryCount, retries on next connectivity event
7. Pull: background refresh pulls latest data from Supabase → upserts into Drift
```

---

## Row-Level Security (RLS)

### Policy Pattern
```sql
-- Users can only access children within their jurisdiction
CREATE POLICY "children_access" ON children
  USING (
    CASE
      WHEN role = 'AWW' THEN awc_id = user_awc_id
      WHEN role = 'SUPERVISOR' THEN awc_id IN (SELECT id FROM awcs WHERE sector_id = user_sector_id)
      WHEN role = 'CDPO' THEN awc_id IN (SELECT id FROM awcs WHERE sector_id IN (SELECT id FROM sectors WHERE project_id = user_project_id))
      ...
    END
  );
```

### Role-Based Data Access
| Role | Scope | Data Access |
|------|-------|-------------|
| PARENT | Own children | Own children's profiles and results |
| AWW | Single AWC | All children in assigned AWC |
| SUPERVISOR | Sector | All children across sector's AWCs |
| CDPO/CW/EO | Project | All children across project's sectors |
| DW | District | All children across district's projects |
| SENIOR_OFFICIAL | State | All children in state |
| ADMIN | Global | Full access |

---

## Screening Tools

The platform supports 16 screening tools via a plug-in architecture:

| Tool | Type | Age Range | Format | Domains |
|------|------|-----------|--------|---------|
| CDC Milestones | cdcMilestones | 0-72 mo | Yes/No | GM, FM, LC, COG, SE |
| RBSK Physical | rbskPhysical | 0-72 mo | Yes/No | Physical examination |
| M-CHAT-R/F | mchatrf | 16-30 mo | Yes/No | Autism screening |
| ISAA | isaa | 18-72 mo | Likert | Autism spectrum |
| ADHD Rating | adhdRating | 36-72 mo | Likert | Attention/hyperactivity |
| RBSK Behavioral | rbskBehavioral | 0-72 mo | Yes/No | Behavioral concerns |
| SDQ | sdq | 24-72 mo | Likert | Strengths/Difficulties |
| Parent-Child Interaction | parentChild | 0-72 mo | Likert | Caregiver interaction |
| PHQ-9 | phq9 | 0-72 mo | Likert | Maternal mental health |
| Home Stimulation | homeStimulation | 0-72 mo | Yes/No | Home environment |
| Nutrition | nutritionAssessment | 0-72 mo | Mixed | Nutritional status |
| Home Environment | homeEnvironment | 0-72 mo | Mixed | Living conditions |
| Birth Defects | rbskBirthDefects | 0-72 mo | Yes/No | Congenital conditions |
| Disease Screening | rbskDiseases | 0-72 mo | Yes/No | Common diseases |

### Tool Plugin Architecture
```dart
// Adding a new screening tool requires 3 files:
// 1. lib/data/tool_{name}.dart       → Questions & config
// 2. lib/data/screening_tools_registry.dart  → Register tool
// 3. lib/utils/scoring/tool_scorer.dart      → Scoring logic
```

---

## Interoperability

### Data Export Formats

#### Excel Export
- Endpoint: `POST /api/export/child/{childId}/excel`
- Format: XLSX with child profile, screening history, DQ scores, risk levels
- Saved to device Downloads folder with filename: `BalVikas_{childName}_{date}.xlsx`

#### JSON Export
- All Supabase endpoints return standard JSON
- Child data includes nested AWC information via joins
- Screening results include full session and child details

### External System Integration Points

#### ICDS/Poshan Tracker
- Data mapping: AWC → Anganwadi Centre, Child → Beneficiary
- Common fields: name, dob, gender, AWC code, nutrition metrics
- Integration: Export screening results in Poshan Tracker-compatible format

#### RBSK/DEIC Referral System
- Referral types map to RBSK facility codes
- Referral reasons align with RBSK screening categories
- Status tracking: Pending → In Progress → Completed

#### HL7 FHIR (Future)
- Child → FHIR Patient resource
- Screening → FHIR Observation resource
- Referral → FHIR ServiceRequest resource
- Assessment → FHIR QuestionnaireResponse resource

---

## Error Handling

### HTTP Status Codes
| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (token expired/invalid) |
| 403 | Forbidden (RLS policy violation) |
| 404 | Not Found |
| 409 | Conflict (duplicate entry) |
| 500 | Internal Server Error |

### Error Response Format
```json
{
  "error": "Error type",
  "message": "Human-readable description",
  "details": { "field": "Specific field error" }
}
```

---

## Rate Limits & Performance

| Metric | Pilot | District | State | National |
|--------|-------|----------|-------|----------|
| Concurrent Users | 20 | 200 | 4,000 | 500,000+ |
| API Calls/min | 100 | 1,000 | 10,000 | 100,000 |
| DB Size | <1 GB | ~5 GB | ~100 GB | ~10 TB |
| Sync Frequency | Real-time | 5 min | 15 min | 30 min |

### Optimization Strategies
- **Pagination:** 50 records per page for list endpoints
- **Selective Sync:** Only sync data within user's jurisdiction
- **Caching:** Dashboard stats cached locally with 5-minute TTL
- **Background Processing:** Sync runs in background isolate
- **Connection Pooling:** PgBouncer for Supabase at scale
