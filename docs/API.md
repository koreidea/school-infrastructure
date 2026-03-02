# API Reference — Vidya Soudha Backend

## Overview

The Vidya Soudha ML backend is a **FastAPI** application providing AI-powered enrolment forecasting, demand validation, and analytics endpoints.

- **Base URL**: `http://localhost:8000`
- **API Prefix**: `/api`
- **Docs**: `http://localhost:8000/docs` (Swagger UI)
- **Health**: `http://localhost:8000/health`

---

## Health Check

### `GET /health`

Check if the backend is running.

**Response:**
```json
{
  "status": "ok",
  "service": "school-infra-backend"
}
```

---

## Forecast Endpoints

### `POST /api/forecast/enrolment/{school_id}`

Predict future enrolment for a specific school using Linear Regression.

**Parameters:**
| Name | In | Type | Default | Description |
|------|-----|------|---------|-------------|
| school_id | path | integer | required | School ID |
| years_ahead | query | integer | 1 | Number of years to forecast (1-5) |

**Request:**
```bash
curl -X POST "http://localhost:8000/api/forecast/enrolment/5?years_ahead=3"
```

**Response (200):**
```json
{
  "school_id": 5,
  "forecasts": [
    {
      "school_id": 5,
      "forecast_year": "2026-27",
      "grade": "ALL",
      "predicted_total": 329,
      "confidence": 0.95,
      "model_used": "LinearRegression"
    },
    {
      "school_id": 5,
      "forecast_year": "2027-28",
      "grade": "ALL",
      "predicted_total": 269,
      "confidence": 0.95,
      "model_used": "LinearRegression"
    },
    {
      "school_id": 5,
      "forecast_year": "2028-29",
      "grade": "ALL",
      "predicted_total": 210,
      "confidence": 0.95,
      "model_used": "LinearRegression"
    }
  ],
  "overall_trend": "DECLINING",
  "growth_rate": -11.85
}
```

**Error (404):**
```json
{"detail": "No enrolment data found for school"}
```

---

### `POST /api/forecast/batch`

Run forecasting for all schools in the database.

**Request Body:**
```json
{
  "years_ahead": 1
}
```

**Response (200):**
```json
{
  "total_processed": 285,
  "total_errors": 34,
  "results": [
    {"school_id": 1, "trend": "DECLINING", "growth_rate": -3.84, "forecast_count": 1},
    {"school_id": 2, "trend": "GROWING", "growth_rate": 5.2, "forecast_count": 1}
  ],
  "errors": [
    {"school_id": 100, "error": "Insufficient data for regression"}
  ]
}
```

---

## Validation Endpoints

### `POST /api/validate/demand-plan`

Validate demand plans using ML anomaly detection + rule-based checks.

**Request Body:**
```json
{
  "demands": [
    {
      "school_id": 42,
      "infra_type": "CWSN_RESOURCE_ROOM",
      "physical_count": 2,
      "financial_amount": 58.6,
      "school_category": "HS",
      "total_enrolment": 450
    }
  ]
}
```

**Response (200):**
```json
{
  "results": [
    {
      "school_id": 42,
      "infra_type": "CWSN_RESOURCE_ROOM",
      "is_anomaly": false,
      "anomaly_score": 0.15,
      "validation_status": "APPROVED",
      "reasons": [],
      "confidence": 0.92
    }
  ],
  "total_flagged": 0,
  "total_approved": 1
}
```

**Validation Status Values:**
| Status | Score Range | Meaning |
|--------|-----------|---------|
| APPROVED | >= 80 | Passes validation checks |
| FLAGGED | 50-79 | Needs officer review |
| REJECTED | < 50 | Multiple check failures |

---

### `POST /api/validate/batch`

Validate all pending demand plans in the database.

**Request:** No body required.

**Response (200):**
```json
{
  "total_processed": 43,
  "total_approved": 28,
  "total_flagged": 12,
  "total_rejected": 3,
  "results": [...]
}
```

---

## Analytics Endpoints

### `GET /api/analytics/state`

Get state-level summary analytics.

**Response (200):**
```json
{
  "total_schools": 319,
  "total_districts": 57,
  "total_mandals": 707,
  "total_enrolment": 142500,
  "total_demand_financial": 4523.5,
  "priority_distribution": {
    "CRITICAL": 15,
    "HIGH": 45,
    "MEDIUM": 120,
    "LOW": 139
  },
  "infra_demand_by_type": {
    "CWSN_RESOURCE_ROOM": 150,
    "CWSN_TOILET": 200,
    "DRINKING_WATER": 180,
    "ELECTRIFICATION": 120,
    "RAMPS": 149
  },
  "top_priority_districts": [
    {"district_id": 12, "district_name": "Srikakulam", "avg_priority": 72.5}
  ]
}
```

---

### `GET /api/analytics/district/{district_id}`

Get analytics for a specific district.

**Parameters:**
| Name | In | Type | Description |
|------|-----|------|-------------|
| district_id | path | integer | District ID |

**Response (200):**
```json
{
  "district_id": 12,
  "district_name": "Srikakulam",
  "total_schools": 8,
  "total_enrolment": 3200,
  "avg_enrolment": 400.0,
  "total_demand_physical": 25,
  "total_demand_financial": 156.75,
  "priority_distribution": {"CRITICAL": 2, "HIGH": 3, "MEDIUM": 2, "LOW": 1},
  "infra_gaps": {"CWSN_RESOURCE_ROOM": 5, "DRINKING_WATER": 3}
}
```

---

## Pydantic Schemas

### Request Models

```python
class ForecastRequest(BaseModel):
    school_id: int
    years_ahead: int = 1

class BatchForecastRequest(BaseModel):
    years_ahead: int = 1

class DemandPlanInput(BaseModel):
    school_id: int
    infra_type: str
    physical_count: int
    financial_amount: float
    school_category: Optional[str] = None
    total_enrolment: Optional[int] = None

class DemandValidationRequest(BaseModel):
    demands: list[DemandPlanInput]
```

### Response Models

```python
class ForecastResult(BaseModel):
    school_id: int
    forecast_year: str
    grade: str
    predicted_total: int
    confidence: float
    model_used: str

class ForecastResponse(BaseModel):
    school_id: int
    forecasts: list[ForecastResult]
    overall_trend: str    # GROWING, DECLINING, STABLE
    growth_rate: float

class ValidationResult(BaseModel):
    school_id: int
    infra_type: str
    is_anomaly: bool
    anomaly_score: float
    validation_status: str  # APPROVED, FLAGGED, REJECTED
    reasons: list[str]
    confidence: float

class DemandValidationResponse(BaseModel):
    results: list[ValidationResult]
    total_flagged: int
    total_approved: int
```

---

## Error Handling

All endpoints return standard HTTP error codes:

| Code | Description | Example |
|------|------------|---------|
| 200 | Success | Normal response |
| 404 | Not Found | School has no enrolment data |
| 422 | Validation Error | Invalid request body |
| 500 | Internal Error | Database or ML model failure |

Error response format:
```json
{
  "detail": "Error description message"
}
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SUPABASE_URL` | (required) | Supabase project URL |
| `SUPABASE_KEY` | (required) | Supabase anon/service key |

### CORS

The backend allows all origins for development:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## Flutter Integration

The Flutter app connects to the backend via `ApiService` (Dio HTTP client):

```dart
// Base URL configured in api_config.dart
// For Android emulator: http://10.0.2.2:8000
// For physical device: http://localhost:8000

static final Dio _dio = Dio(BaseOptions(
  baseUrl: ApiConfig.fullBaseUrl,  // http://10.0.2.2:8000/api
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 30),
));
```

### Fallback Behavior
If the backend is unreachable, the app automatically falls back to client-side algorithms:
- **Forecast**: Linear extrapolation from historical data
- **Validation**: 7-rule engine without Isolation Forest
- **Analytics**: Computed from cached Supabase data
