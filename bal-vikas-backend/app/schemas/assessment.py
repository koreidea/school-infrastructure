from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal


class DevelopmentalAssessmentData(BaseModel):
    gm_dq: Optional[float] = None
    fm_dq: Optional[float] = None
    lc_dq: Optional[float] = None
    cog_dq: Optional[float] = None
    se_dq: Optional[float] = None
    composite_dq: Optional[float] = None


class DevelopmentalRiskData(BaseModel):
    gm_delay: bool = False
    fm_delay: bool = False
    lc_delay: bool = False
    cog_delay: bool = False
    se_delay: bool = False
    num_delays: int = 0


class NutritionData(BaseModel):
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    head_circumference_cm: Optional[float] = None
    height_z_score: Optional[float] = None
    weight_z_score: Optional[float] = None
    wfh_z_score: Optional[float] = None
    underweight: int = 0
    stunting: int = 0
    wasting: int = 0
    anemia: int = 0
    nutrition_score: Optional[int] = None
    nutrition_risk: Optional[str] = None


class NeuroBehavioralData(BaseModel):
    autism_risk: Optional[str] = None
    adhd_risk: Optional[str] = None
    behavior_risk: Optional[str] = None
    mchat_score: Optional[int] = None
    isaa_score: Optional[int] = None
    adhd_score: Optional[int] = None
    sdq_total_score: Optional[int] = None


class BaselineRiskData(BaseModel):
    overall_risk_category: Optional[str] = None
    primary_concern: Optional[str] = None
    secondary_concerns: Optional[str] = None
    referral_needed: bool = False
    intervention_priority: Optional[str] = None


class AssessmentResultResponse(BaseModel):
    session_id: int
    child_id: int
    developmental: Optional[DevelopmentalAssessmentData] = None
    risk: Optional[DevelopmentalRiskData] = None
    nutrition: Optional[NutritionData] = None
    neuro_behavioral: Optional[NeuroBehavioralData] = None
    baseline_risk: Optional[BaselineRiskData] = None
