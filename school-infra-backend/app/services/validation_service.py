"""
Demand Plan Validation Service — ML-based anomaly detection.

Uses:
1. Isolation Forest for anomaly detection
2. Rule-based validation against Samagra Shiksha norms
3. Statistical outlier detection
"""

import numpy as np
from sklearn.ensemble import IsolationForest
from app.services.db import get_db

# Samagra Shiksha standard unit costs (in Lakhs)
UNIT_COSTS = {
    "CWSN_RESOURCE_ROOM": 29.3,
    "CWSN_TOILET": 4.65,
    "DRINKING_WATER": 3.40,
    "ELECTRIFICATION": 1.75,
    "RAMPS": 1.25,
}

# Student-to-facility norms
NORMS = {
    "CWSN_RESOURCE_ROOM": {"per_students": 150, "min_enrolment": 50},
    "CWSN_TOILET": {"per_students": 80, "min_enrolment": 20},
    "DRINKING_WATER": {"per_students": 100, "min_enrolment": 10},
    "ELECTRIFICATION": {"per_school": 1},
    "RAMPS": {"per_school": 1},
}


def validate_demand_plans(demands: list[dict]) -> list[dict]:
    """Validate a batch of demand plans using ML + rules."""
    if not demands:
        return []

    results = []

    # Rule-based validation
    for demand in demands:
        result = _rule_based_validation(demand)
        results.append(result)

    # ML anomaly detection (if enough data)
    if len(demands) >= 5:
        _ml_anomaly_detection(demands, results)

    return results


def _rule_based_validation(demand: dict) -> dict:
    """Apply Samagra Shiksha norm-based rules."""
    reasons = []
    score = 100.0
    infra_type = demand.get("infra_type", "")
    physical_count = demand.get("physical_count", 0)
    financial_amount = demand.get("financial_amount", 0.0)
    total_enrolment = demand.get("total_enrolment", 0)

    # Rule 1: Unit cost validation
    expected_cost = UNIT_COSTS.get(infra_type, 0)
    if expected_cost > 0 and physical_count > 0:
        actual_unit_cost = financial_amount / physical_count
        deviation = abs(actual_unit_cost - expected_cost) / expected_cost
        if deviation > 0.3:
            reasons.append(f"Unit cost deviation: {deviation*100:.0f}% from standard ₹{expected_cost}L")
            score -= 25
        elif deviation > 0.15:
            reasons.append(f"Moderate cost deviation: {deviation*100:.0f}%")
            score -= 10

    # Rule 2: Zero value checks
    if physical_count <= 0:
        reasons.append("Physical count is zero or negative")
        score -= 30
    if financial_amount <= 0:
        reasons.append("Financial amount is zero or negative")
        score -= 30

    # Rule 3: Enrolment-demand correlation
    norms = NORMS.get(infra_type, {})
    if total_enrolment and total_enrolment > 0:
        per_students = norms.get("per_students")
        if per_students:
            expected_units = max(1, total_enrolment // per_students)
            if physical_count > expected_units * 3:
                reasons.append(f"Demand ({physical_count}) exceeds 3x expected ({expected_units}) for enrolment {total_enrolment}")
                score -= 20

        min_enrolment = norms.get("min_enrolment", 0)
        if total_enrolment < min_enrolment:
            reasons.append(f"School enrolment ({total_enrolment}) below minimum ({min_enrolment}) for {infra_type}")
            score -= 15

    # Rule 4: Per-school limit
    per_school = norms.get("per_school")
    if per_school and physical_count > per_school * 2:
        reasons.append(f"Demand ({physical_count}) exceeds 2x per-school limit ({per_school})")
        score -= 15

    # Rule 5: Excessive financial amount
    if financial_amount > 50:  # > 50 Lakhs for a single item
        reasons.append(f"Very high financial amount: ₹{financial_amount}L")
        score -= 10

    score = max(0, min(100, score))

    if score >= 80:
        status = "APPROVED"
    elif score >= 50:
        status = "FLAGGED"
    else:
        status = "REJECTED"

    return {
        "school_id": demand.get("school_id", 0),
        "infra_type": infra_type,
        "is_anomaly": score < 50,
        "anomaly_score": round(1 - score / 100, 3),
        "validation_status": status,
        "reasons": reasons if reasons else ["Passed all validation checks"],
        "confidence": round(score / 100, 3),
    }


def _ml_anomaly_detection(demands: list[dict], results: list[dict]):
    """Apply Isolation Forest anomaly detection to demand features."""
    # Build feature matrix
    features = []
    for d in demands:
        physical = d.get("physical_count", 0)
        financial = d.get("financial_amount", 0.0)
        enrolment = d.get("total_enrolment", 0) or 100  # default
        unit_cost = financial / max(physical, 1)
        cost_per_student = financial / max(enrolment, 1)

        features.append([
            physical,
            financial,
            unit_cost,
            cost_per_student,
            enrolment,
        ])

    X = np.array(features)

    # Fit Isolation Forest
    iso_forest = IsolationForest(
        contamination=0.15,
        random_state=42,
        n_estimators=100,
    )
    predictions = iso_forest.fit_predict(X)
    anomaly_scores = iso_forest.decision_function(X)

    # Update results with ML scores
    for i, (pred, a_score) in enumerate(zip(predictions, anomaly_scores)):
        if i < len(results):
            is_ml_anomaly = pred == -1
            ml_anomaly_score = float(-a_score)  # Higher = more anomalous

            if is_ml_anomaly:
                results[i]["is_anomaly"] = True
                if "ML anomaly detected" not in results[i]["reasons"]:
                    results[i]["reasons"].append(f"ML anomaly detected (score: {ml_anomaly_score:.2f})")
                # Downgrade status if ML flags it
                if results[i]["validation_status"] == "APPROVED":
                    results[i]["validation_status"] = "FLAGGED"
                    results[i]["confidence"] = max(0.4, results[i]["confidence"] - 0.2)


def get_all_demand_plans() -> list[dict]:
    """Fetch all demand plans from DB for batch validation."""
    db = get_db()
    result = db.table("si_demand_plans_view").select("*").execute()
    return result.data
