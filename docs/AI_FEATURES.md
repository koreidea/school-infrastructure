# AI/ML Features — Vidya Soudha

## Overview

Vidya Soudha implements 4 core AI/ML capabilities for school infrastructure planning:

1. **Demand Validation** — Rule-based + ML anomaly detection
2. **Priority Scoring** — 4-factor composite scoring algorithm
3. **Enrolment Forecasting** — Linear Regression + Cohort Progression
4. **Budget Optimization** — Strategy-based allocation planning

All features follow an **offline-first** design: backend ML models enhance accuracy when available, client-side algorithms ensure functionality without network.

---

## 1. Demand Validation Engine

### Architecture
```
Demand Plan Input
      |
      v
[Client-Side: 7-Rule Engine]  ----+
      |                            |
      v                            v
[Backend: Isolation Forest]   [Fallback: Rule-Only]
      |                            |
      v                            v
   Combined Result             Rule-Only Result
   (AI-Enhanced)               (Rule-Based)
```

### 7 Validation Rules

| # | Rule | Flag Code | Logic | Weight |
|---|------|-----------|-------|--------|
| 1 | **Unit Cost Deviation** | `COST_ANOMALY` | Cost per unit deviates >30% from Samagra Shiksha norms | High |
| 2 | **Duplicate Detection** | `DUPLICATE` | Same school + infra type in same academic year | Critical |
| 3 | **Enrolment Correlation** | `ENROLMENT_MISMATCH` | Demand volume disproportionate to school enrolment | Medium |
| 4 | **Peer Comparison** | `PEER_OUTLIER` | Cost >2 standard deviations from peer schools | Medium |
| 5 | **Zero-Value Check** | `ZERO_VALUE` | Physical count or financial amount is zero/negative | Critical |
| 6 | **Existing Infrastructure** | `EXISTING_INFRA` | School already has the requested facility | Medium |
| 7 | **Over-Reporting** | `OVER_REPORTING` | School requests excessive infra across multiple types | Low |

### Scoring
- Each rule contributes to a composite validation score (0-100)
- Score thresholds:
  - **APPROVED** (>= 80): Passes most checks, minor deviations acceptable
  - **FLAGGED** (50-79): Needs officer review, some rules failed
  - **REJECTED** (< 50): Multiple critical rule failures

### Explainability (XAI)
Every validation result includes per-rule breakdown:
```json
{
  "rules": [
    {"name": "Unit Cost Deviation", "passed": true, "detail": "Cost within 15% of norm (₹29.3L)"},
    {"name": "Duplicate Detection", "passed": false, "detail": "Duplicate CWSN_TOILET request found for 2024-25"},
    ...
  ],
  "overall_score": 65,
  "status": "FLAGGED",
  "flags": ["DUPLICATE"]
}
```

### Isolation Forest (Backend ML)
- **Algorithm**: scikit-learn `IsolationForest(contamination=0.1, random_state=42)`
- **Features**: physical_count, financial_amount, cost_per_unit, school_enrolment
- **Training**: Fitted on all non-flagged demand plans
- **Output**: anomaly_score (0-1), is_anomaly (boolean)
- **Integration**: Combined with rule-based score for final result

### Implementation Files
- `lib/services/demand_validation_service.dart` — Client-side 7-rule engine
- `school-infra-backend/app/services/validation_service.py` — Backend ML + rules
- `lib/screens/dashboard/tabs/validation_tab.dart` — UI with XAI breakdown

---

## 2. Composite Priority Scoring

### Algorithm
4-factor weighted scoring to rank schools for equitable resource allocation:

```
Composite Score = (Enrolment Pressure * 0.30)
               + (Infrastructure Gap * 0.30)
               + (CWSN Needs * 0.20)
               + (Accessibility * 0.20)
```

### Factor Calculations

#### Enrolment Pressure (30%)
```python
student_classroom_ratio = total_enrolment / num_classrooms
norm = 30 (primary) or 35 (secondary)
score = min(100, (ratio / norm) * 50)
# Higher ratio = more pressure = higher score
```

#### Infrastructure Gap (30%)
```python
missing_facilities = count of (no water, no electricity, no toilet, no ramp, no CWSN room)
total_facilities = 5
score = (missing_facilities / total_facilities) * 100
# More missing = higher gap = higher score
```

#### CWSN Needs (20%)
```python
cwsn_facilities_missing = count of (no CWSN room, no CWSN toilet, no ramp)
score = (cwsn_facilities_missing / 3) * 100
# Schools lacking CWSN facilities get higher priority
```

#### Accessibility (20%)
```python
accessibility_features_missing = count of (no ramp, no CWSN toilet)
score = (accessibility_features_missing / 2) * 100
# Schools without accessibility features prioritized
```

### Priority Levels
| Level | Score Range | Color | Description |
|-------|------------|-------|-------------|
| CRITICAL | > 80 | Red | Immediate intervention required |
| HIGH | 60-80 | Orange | Urgent attention needed |
| MEDIUM | 40-60 | Yellow | Standard improvement planned |
| LOW | <= 40 | Green | Adequate infrastructure |

### Auto-Computation
- Priority scores are computed on first dashboard load if `si_school_priority_scores` is empty
- Batch computation processes all 319 schools using `PriorityScoringService.computeAll()`
- Scores stored in Supabase for subsequent fast retrieval

### Implementation Files
- `lib/services/priority_scoring_service.dart` — Scoring algorithm
- `lib/providers/dashboard_provider.dart` — Auto-compute trigger
- `lib/screens/schools/school_profile_screen.dart` — Score breakdown card

---

## 3. Enrolment Forecasting

### Backend Model: Linear Regression

```python
# Model: scikit-learn LinearRegression
from sklearn.linear_model import LinearRegression

# Features: year index (0, 1, 2, ...)
# Target: total enrolment per year
# Training: Historical enrolment records (2-5 years)

model = LinearRegression()
model.fit(X_years, y_enrolment)
predictions = model.predict(X_future_years)
```

**Cohort Progression** (supplementary model):
- Tracks grade-to-grade transitions (Grade 1 -> 2 -> 3...)
- Accounts for dropout rates and grade retention
- Provides grade-level predictions (not just totals)

### Client-Side Fallback: Linear Extrapolation

```dart
// Compute growth rate from historical data
final trend = EnrolmentTrend.compute(schoolId, records);
final annualGrowthRate = trend.growthRate / (years - 1);

// Project 3 years with declining confidence
for (int i = 1; i <= 3; i++) {
  predicted = lastTotal * pow(1 + growthRate/100, i);
  confidence = 0.90 - (i * 0.10);  // 90%, 80%, 70%
}
```

### Output Format
```json
{
  "school_id": 5,
  "overall_trend": "DECLINING",
  "growth_rate": -3.84,
  "model": "backend_ml",
  "forecasts": [
    {"forecast_year": "2026-27", "grade": "ALL", "predicted_total": 329, "confidence": 0.95, "model_used": "LinearRegression"},
    {"forecast_year": "2027-28", "grade": "ALL", "predicted_total": 269, "confidence": 0.95, "model_used": "LinearRegression"},
    {"forecast_year": "2028-29", "grade": "ALL", "predicted_total": 210, "confidence": 0.95, "model_used": "LinearRegression"}
  ]
}
```

### UI Indicators
- **Green badge**: "AI-Enhanced: LinearRegression" (backend model used)
- **Blue badge**: "Rule-Based: Client-side linear extrapolation" (fallback used)

### Implementation Files
- `school-infra-backend/app/services/forecast_service.py` — Backend ML
- `lib/providers/dashboard_provider.dart` — Client fallback in `ForecastNotifier`
- `lib/models/enrolment.dart` — `EnrolmentTrend.compute()` utility

---

## 4. Budget Allocation Planner

### Three Strategies

| Strategy | Multiplier | Description |
|----------|-----------|-------------|
| **Conservative** | 0.60x | Essential repairs only, 60% of standard cost |
| **Balanced** | 1.00x | Full Samagra Shiksha norm allocation |
| **Growth-Oriented** | 1.30x+ | Includes enrolment growth buffer from forecast |

### Calculation
```dart
// For each infrastructure type in demand plans:
baseCost = physicalCount * unitCost[infraType]

// Apply strategy multiplier:
conservativeCost = baseCost * 0.60
balancedCost = baseCost * 1.00
growthCost = baseCost * (1.0 + growthRate + 0.30)
```

### Integration with Forecast
The Growth-Oriented strategy uses the enrolment forecast growth rate to scale infrastructure needs:
- If enrolment is growing 5%/year, infra needs increase proportionally
- Buffer of 30% added on top of growth for proactive planning
- Shows breakdown by infrastructure type with expandable cards

### Implementation Files
- `lib/screens/schools/school_profile_screen.dart` — `_BudgetAllocationPlanner`
- `lib/screens/dashboard/tabs/analytics_tab.dart` — State-level budget planner

---

## 5. Responsible AI / Fairness Analysis

### Bias Checks (Documented in Notebook)
1. **Category fairness**: Do validation flags disproportionately affect certain school categories (PS vs HSS)?
2. **Management fairness**: Are government schools flagged more than private schools?
3. **District equity**: Is priority score distribution even across districts?
4. **CWSN focus**: Do schools with CWSN needs receive appropriate priority?

### Mitigation Strategies
- CWSN needs weighted at 20% in priority scoring to ensure inclusive resource allocation
- Accessibility weighted at 20% to prevent neglect of disabled-accessible infrastructure
- Peer comparison uses same-category peers (not cross-category) to avoid unfair comparison
- Over-reporting check considers school size to avoid penalizing larger schools

---

## Model Performance Metrics

### Computed from Live Data (Analytics Tab)

| Metric | Description | Computation |
|--------|-------------|-------------|
| Validation Coverage | % of demands validated | validated / total demands |
| Anomaly Detection Rate | % flagged as anomalous | (flagged + rejected) / validated |
| Approval Rate | % approved | approved / validated |
| F1 Score | Harmonic mean of precision & recall | 2 * P * R / (P + R) |
| Avg Validation Score | Mean confidence score | mean(validation_scores) |
| Priority Scoring | Schools with computed scores | count(priority_scores) |

### Notebook Evaluation (model_analysis.ipynb)

| Model | Metric | Value |
|-------|--------|-------|
| Random Forest Classifier | Accuracy | 1.000 |
| Isolation Forest | AUC-ROC | 0.983 |
| Linear Regression (Forecast) | R-squared | 0.9206 |
| Linear Regression (Forecast) | RMSE | 42.3 |

### Generated Visualizations (16 Charts)
1. `missing_values.png` — Data quality heatmap
2. `infra_distribution.png` — Infrastructure availability distribution
3. `enrolment_trends.png` — Year-over-year enrolment patterns
4. `validation_distribution.png` — Validation status distribution
5. `priority_analysis.png` — Priority level breakdown
6. `feature_correlation.png` — Feature correlation matrix
7. `isolation_forest.png` — Anomaly detection scatter plot
8. `feature_importance.png` — Random Forest feature importances
9. `forecast_evaluation.png` — Forecast vs actual comparison
10. `confusion_matrices.png` — Classification confusion matrices
11. `roc_curves.png` — ROC curves for all models
12. `model_comparison.png` — Model performance comparison
13. `priority_factors.png` — 4-factor score distribution
14. `fairness_priority.png` — District-level fairness analysis
15. `gender_distribution.png` — Boys vs girls enrolment
16. `category_analysis.png` — School category breakdown
