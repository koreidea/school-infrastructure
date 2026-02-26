"""Pydantic models for API request/response schemas."""

from pydantic import BaseModel
from typing import Optional


class EnrolmentData(BaseModel):
    academic_year: str
    grade: str
    boys: int = 0
    girls: int = 0
    total: int = 0


class ForecastRequest(BaseModel):
    school_id: int
    years_ahead: int = 1


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
    overall_trend: str  # GROWING, DECLINING, STABLE
    growth_rate: float


class BatchForecastRequest(BaseModel):
    years_ahead: int = 1


class DemandPlanInput(BaseModel):
    school_id: int
    infra_type: str
    physical_count: int
    financial_amount: float
    school_category: Optional[str] = None
    total_enrolment: Optional[int] = None


class ValidationResult(BaseModel):
    school_id: int
    infra_type: str
    is_anomaly: bool
    anomaly_score: float
    validation_status: str  # APPROVED, FLAGGED, REJECTED
    reasons: list[str]
    confidence: float


class DemandValidationRequest(BaseModel):
    demands: list[DemandPlanInput]


class DemandValidationResponse(BaseModel):
    results: list[ValidationResult]
    total_flagged: int
    total_approved: int


class DistrictAnalytics(BaseModel):
    district_id: int
    district_name: str
    total_schools: int
    total_enrolment: int
    avg_enrolment: float
    total_demand_physical: int
    total_demand_financial: float
    priority_distribution: dict[str, int]
    infra_gaps: dict[str, int]


class StateAnalytics(BaseModel):
    total_schools: int
    total_districts: int
    total_mandals: int
    total_enrolment: int
    total_demand_financial: float
    priority_distribution: dict[str, int]
    infra_demand_by_type: dict[str, int]
    top_priority_districts: list[dict]
