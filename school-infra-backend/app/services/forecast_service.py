"""
Enrolment Forecasting Service

Models:
1. Linear Regression — trend extrapolation (baseline)
2. Cohort Progression — track student cohorts across grades/years
"""

import numpy as np
from sklearn.linear_model import LinearRegression
from app.services.db import get_db


def get_enrolment_data(school_id: int) -> list[dict]:
    """Fetch enrolment history for a school."""
    db = get_db()
    result = db.table("si_enrolment_history") \
        .select("*") \
        .eq("school_id", school_id) \
        .order("academic_year") \
        .execute()
    return result.data


def forecast_school(school_id: int, years_ahead: int = 1) -> dict:
    """Generate enrolment forecast for a school."""
    records = get_enrolment_data(school_id)
    if not records:
        return {"school_id": school_id, "forecasts": [], "overall_trend": "STABLE", "growth_rate": 0.0}

    # Group by year
    by_year = {}
    for r in records:
        yr = r["academic_year"]
        by_year.setdefault(yr, {"boys": 0, "girls": 0, "total": 0})
        by_year[yr]["boys"] += r.get("boys", 0)
        by_year[yr]["girls"] += r.get("girls", 0)
        by_year[yr]["total"] += r.get("total", 0)

    years = sorted(by_year.keys())
    if len(years) < 2:
        return {
            "school_id": school_id,
            "forecasts": [],
            "overall_trend": "STABLE",
            "growth_rate": 0.0,
        }

    # Linear regression on total enrolment
    X = np.arange(len(years)).reshape(-1, 1)
    y_total = np.array([by_year[yr]["total"] for yr in years])
    y_boys = np.array([by_year[yr]["boys"] for yr in years])
    y_girls = np.array([by_year[yr]["girls"] for yr in years])

    model_total = LinearRegression().fit(X, y_total)
    model_boys = LinearRegression().fit(X, y_boys)
    model_girls = LinearRegression().fit(X, y_girls)

    # Calculate growth rate
    if y_total[0] > 0:
        growth_rate = ((y_total[-1] - y_total[0]) / y_total[0]) * 100 / max(len(years) - 1, 1)
    else:
        growth_rate = 0.0

    # Determine trend
    if growth_rate > 2:
        trend = "GROWING"
    elif growth_rate < -2:
        trend = "DECLINING"
    else:
        trend = "STABLE"

    # Generate forecasts
    forecasts = []
    last_year_parts = years[-1].split("-")

    # Confidence = model_fit × data_quality × horizon_decay × volatility_factor
    # model_fit: R² score of linear regression (how well the line fits)
    r2 = float(model_total.score(X, y_total))
    model_fit = max(0.5, min(0.98, r2))

    # data_quality: more historical years = more reliable
    n_years = len(years)
    if n_years >= 5:
        data_quality = 0.93
    elif n_years >= 4:
        data_quality = 0.88
    elif n_years >= 3:
        data_quality = 0.82
    else:
        data_quality = 0.75

    # volatility_factor: penalize if year-to-year changes are erratic
    volatility_factor = 1.0
    if n_years >= 3:
        changes = []
        for j in range(1, n_years):
            prev = y_total[j - 1]
            curr = y_total[j]
            if prev > 0:
                changes.append(abs(curr - prev) / prev)
        if changes:
            avg_change = sum(changes) / len(changes)
            if avg_change > 0.25:
                volatility_factor = 0.85
            elif avg_change > 0.15:
                volatility_factor = 0.92

    # horizon_decay: further predictions are less reliable
    horizon_decay = {1: 1.0, 2: 0.92, 3: 0.82}

    for ahead in range(1, years_ahead + 1):
        future_x = np.array([[len(years) - 1 + ahead]])
        pred_total = max(0, int(model_total.predict(future_x)[0]))
        pred_boys = max(0, int(model_boys.predict(future_x)[0]))
        pred_girls = max(0, int(model_girls.predict(future_x)[0]))

        # Compute forecast year string
        try:
            start_yr = int(last_year_parts[0]) + ahead
            end_yr = int("20" + last_year_parts[1]) + ahead if len(last_year_parts[1]) == 2 else int(last_year_parts[1]) + ahead
            forecast_year = f"{start_yr}-{str(end_yr)[-2:]}"
        except (ValueError, IndexError):
            forecast_year = f"Year+{ahead}"

        decay = horizon_decay.get(ahead, 0.60)
        conf = model_fit * data_quality * decay * volatility_factor
        conf = max(0.20, min(0.95, conf))

        forecasts.append({
            "school_id": school_id,
            "forecast_year": forecast_year,
            "grade": "ALL",
            "predicted_total": pred_total,
            "predicted_boys": pred_boys,
            "predicted_girls": pred_girls,
            "confidence": round(conf, 2),
            "model_used": "LinearRegression",
        })

    # Grade-wise forecasts using cohort progression
    grade_forecasts = _cohort_forecast(records, years, years_ahead)
    forecasts.extend(grade_forecasts)

    return {
        "school_id": school_id,
        "forecasts": forecasts,
        "overall_trend": trend,
        "growth_rate": round(growth_rate, 2),
    }


def _cohort_forecast(records: list[dict], years: list[str], years_ahead: int) -> list[dict]:
    """Cohort progression model: track how students move between grades."""
    # Group by year and grade
    data = {}
    for r in records:
        yr = r["academic_year"]
        grade = r.get("grade", "")
        data.setdefault(yr, {})[grade] = r.get("total", 0)

    grade_order = ["PP3", "PP2", "PP1", "Class 1", "Class 2", "Class 3",
                   "Class 4", "Class 5", "Class 6", "Class 7", "Class 8",
                   "Class 9", "Class 10", "Class 11", "Class 12"]

    # Compute progression rates between consecutive years
    progression_rates = {}
    for i in range(len(years) - 1):
        curr_year = data.get(years[i], {})
        next_year = data.get(years[i + 1], {})
        for j in range(len(grade_order) - 1):
            g_from = grade_order[j]
            g_to = grade_order[j + 1]
            from_count = curr_year.get(g_from, 0)
            to_count = next_year.get(g_to, 0)
            if from_count > 0:
                rate = to_count / from_count
                progression_rates.setdefault((g_from, g_to), []).append(rate)

    # Average progression rates
    avg_rates = {}
    for key, rates in progression_rates.items():
        avg_rates[key] = np.mean(rates)

    # Forecast using progression
    forecasts = []
    last_year = data.get(years[-1], {})
    last_year_parts = years[-1].split("-")

    # Cohort confidence: based on how many year-pairs we have for progression rates
    n_year_pairs = len(years) - 1
    cohort_data_quality = 0.75 if n_year_pairs <= 1 else (
        0.82 if n_year_pairs <= 2 else (0.88 if n_year_pairs <= 3 else 0.93)
    )
    cohort_horizon_decay = {1: 1.0, 2: 0.92, 3: 0.82}

    for ahead in range(1, years_ahead + 1):
        try:
            start_yr = int(last_year_parts[0]) + ahead
            end_yr = int("20" + last_year_parts[1]) + ahead if len(last_year_parts[1]) == 2 else int(last_year_parts[1]) + ahead
            forecast_year = f"{start_yr}-{str(end_yr)[-2:]}"
        except (ValueError, IndexError):
            forecast_year = f"Year+{ahead}"

        decay = cohort_horizon_decay.get(ahead, 0.60)

        for j in range(1, len(grade_order)):
            g_from = grade_order[j - 1]
            g_to = grade_order[j]
            rate = avg_rates.get((g_from, g_to), 0.95)  # Default 95% progression
            from_count = last_year.get(g_from, 0)
            predicted = max(0, int(from_count * rate))

            # Per-grade confidence: if we have actual rate data, higher confidence
            has_actual_rate = (g_from, g_to) in avg_rates
            rate_quality = 0.85 if has_actual_rate else 0.50
            conf = round(max(0.20, min(0.95, cohort_data_quality * decay * rate_quality)), 2)

            if predicted > 0:
                forecasts.append({
                    "school_id": 0,  # Will be set by caller
                    "forecast_year": forecast_year,
                    "grade": g_to,
                    "predicted_total": predicted,
                    "confidence": conf,
                    "model_used": "CohortProgression",
                })

    return forecasts


def save_forecasts(school_id: int, forecasts: list[dict]):
    """Save forecasts to Supabase."""
    db = get_db()
    for f in forecasts:
        f["school_id"] = school_id
        db.table("si_enrolment_forecasts").insert({
            "school_id": school_id,
            "forecast_year": f["forecast_year"],
            "grade": f["grade"],
            "predicted_total": f["predicted_total"],
            "confidence": f["confidence"],
            "model_used": f["model_used"],
        }).execute()
