from fastapi import APIRouter, Depends, HTTPException, Response
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import Dict, Any
from datetime import datetime
import os

from app.database import get_db
from app.models import (
    ScreeningSession, Child, DevelopmentalAssessment, DevelopmentalRisk,
    NeuroBehavioralAssessment, BehaviorIndicators, EnvironmentCaregiving,
    NutritionAssessment, BaselineRiskOutput
)
from app.services.auth_service import AuthService
from app.services.excel_service import ExcelService

router = APIRouter()
security = HTTPBearer()

EXPORT_DIR = "data/exports"
os.makedirs(EXPORT_DIR, exist_ok=True)


def get_current_user_id(credentials: HTTPAuthorizationCredentials = Depends(security)) -> int:
    token = credentials.credentials
    user_id = AuthService.verify_token(token)
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user_id


@router.post("/child/{child_id}/excel")
def export_child_excel(
    child_id: int,
    current_user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    """Export child data as Excel matching ECD sample dataset format"""
    child = db.query(Child).filter(Child.child_id == child_id).first()
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")
    
    # Get latest completed session
    session = db.query(ScreeningSession).filter(
        ScreeningSession.child_id == child_id,
        ScreeningSession.status == 'completed'
    ).order_by(ScreeningSession.created_at.desc()).first()
    
    if not session:
        raise HTTPException(status_code=404, detail="No completed screening found")
    
    # Gather all assessment data
    assessment_data = {
        "child_id": child.child_id,
        "child_unique_id": child.child_unique_id if hasattr(child, 'child_unique_id') else f"CHILD_{child.child_id}",
        "gender": child.gender,
        "child_age_months": session.child_age_months,
        "assessment_date": session.assessment_date.strftime("%Y-%m-%d") if session.assessment_date else "",
        "anganwadi_center_id": child.anganwadi_center_id if hasattr(child, 'anganwadi_center_id') else "",
        "anganwadi_center": child.anganwadi_center.center_name if child.anganwadi_center else "",
        "district": child.anganwadi_center.district if child.anganwadi_center and hasattr(child.anganwadi_center, 'district') else "",
        "mandal": child.anganwadi_center.mandal if child.anganwadi_center and hasattr(child.anganwadi_center, 'mandal') else "",
        "village": child.anganwadi_center.village if child.anganwadi_center and hasattr(child.anganwadi_center, 'village') else "",
    }
    
    # Developmental assessment
    if session.developmental_assessment:
        dev = session.developmental_assessment
        assessment_data["developmental"] = {
            "gm_dq": float(dev.gm_dq) if dev.gm_dq else 0,
            "fm_dq": float(dev.fm_dq) if dev.fm_dq else 0,
            "lc_dq": float(dev.lc_dq) if dev.lc_dq else 0,
            "cog_dq": float(dev.cog_dq) if dev.cog_dq else 0,
            "se_dq": float(dev.se_dq) if dev.se_dq else 0,
            "composite_dq": float(dev.composite_dq) if dev.composite_dq else 0,
        }
        assessment_data["mode_delivery"] = dev.mode_delivery or ""
        assessment_data["mode_conception"] = dev.mode_conception or ""
        assessment_data["birth_status"] = dev.birth_status or ""
        assessment_data["consanguinity"] = dev.consanguinity or ""
    else:
        assessment_data["developmental"] = {
            "gm_dq": 0, "fm_dq": 0, "lc_dq": 0, "cog_dq": 0, "se_dq": 0, "composite_dq": 0
        }
        assessment_data["mode_delivery"] = ""
        assessment_data["mode_conception"] = ""
        assessment_data["birth_status"] = ""
        assessment_data["consanguinity"] = ""
    
    # Risk assessment
    if session.developmental_risk:
        risk = session.developmental_risk
        assessment_data["risk"] = {
            "gm_delay": risk.gm_delay,
            "fm_delay": risk.fm_delay,
            "lc_delay": risk.lc_delay,
            "cog_delay": risk.cog_delay,
            "se_delay": risk.se_delay,
            "num_delays": risk.num_delays,
        }
    else:
        assessment_data["risk"] = {
            "gm_delay": False, "fm_delay": False, "lc_delay": False,
            "cog_delay": False, "se_delay": False, "num_delays": 0
        }
    
    # Neuro behavioral
    if session.neuro_behavioral:
        neuro = session.neuro_behavioral
        assessment_data["neuro_behavioral"] = {
            "autism_risk": neuro.autism_risk or "Low",
            "adhd_risk": neuro.adhd_risk or "Low",
            "behavior_risk": neuro.behavior_risk or "Low",
            "mchat_score": neuro.mchat_score,
            "isaa_score": neuro.isaa_score,
            "adhd_score": neuro.adhd_score,
            "sdq_total_score": neuro.sdq_total_score,
        }
    else:
        assessment_data["neuro_behavioral"] = {
            "autism_risk": "Low", "adhd_risk": "Low", "behavior_risk": "Low",
            "mchat_score": None, "isaa_score": None, "adhd_score": None, "sdq_total_score": None
        }
    
    # Behavior indicators
    if session.behavior_indicators:
        behavior = session.behavior_indicators
        assessment_data["behavior"] = {
            "concerns": behavior.behaviour_concerns or "",
            "score": behavior.behaviour_score,
            "risk_level": behavior.behaviour_risk_level or "Low",
        }
    else:
        assessment_data["behavior"] = {
            "concerns": "", "score": 0, "risk_level": "Low"
        }
    
    # Environment and caregiving
    if session.environment_caregiving:
        env = session.environment_caregiving
        assessment_data["environment"] = {
            "parent_child_interaction_score": env.parent_child_interaction_score or 0,
            "home_stimulation_score": env.home_stimulation_score or 0,
            "play_materials": env.play_materials or False,
            "caregiver_engagement": env.caregiver_engagement or "Low",
            "language_exposure": env.language_exposure or "Low",
            "safe_water": env.safe_water or False,
            "toilet_facility": env.toilet_facility or False,
        }
    else:
        assessment_data["environment"] = {
            "parent_child_interaction_score": 0, "home_stimulation_score": 0,
            "play_materials": False, "caregiver_engagement": "Low",
            "language_exposure": "Low", "safe_water": False, "toilet_facility": False
        }
    
    # Nutrition
    if session.nutrition_assessment:
        nut = session.nutrition_assessment
        assessment_data["nutrition"] = {
            "height_cm": float(nut.height_cm) if nut.height_cm else 0,
            "weight_kg": float(nut.weight_kg) if nut.weight_kg else 0,
            "head_circumference_cm": float(nut.head_circumference_cm) if nut.head_circumference_cm else 0,
            "height_z_score": float(nut.height_z_score) if nut.height_z_score else 0,
            "weight_z_score": float(nut.weight_z_score) if nut.weight_z_score else 0,
            "wfh_z_score": float(nut.wfh_z_score) if nut.wfh_z_score else 0,
            "underweight": nut.underweight or 0,
            "stunting": nut.stunting or 0,
            "wasting": nut.wasting or 0,
            "anemia": nut.anemia or 0,
            "nutrition_score": nut.nutrition_score,
            "nutrition_risk": nut.nutrition_risk or "Low",
        }
    else:
        assessment_data["nutrition"] = {
            "height_cm": 0, "weight_kg": 0, "head_circumference_cm": 0,
            "height_z_score": 0, "weight_z_score": 0, "wfh_z_score": 0,
            "underweight": 0, "stunting": 0, "wasting": 0, "anemia": 0,
            "nutrition_score": 0, "nutrition_risk": "Low"
        }
    
    # Baseline risk
    if session.baseline_risk:
        baseline = session.baseline_risk
        assessment_data["baseline_risk"] = {
            "overall_risk_category": baseline.overall_risk_category or "LOW",
            "primary_concern": baseline.primary_concern or "",
            "secondary_concerns": baseline.secondary_concerns or "",
            "referral_needed": baseline.referral_needed or False,
            "intervention_priority": baseline.intervention_priority or "LOW",
        }
    else:
        assessment_data["baseline_risk"] = {
            "overall_risk_category": "LOW", "primary_concern": "",
            "secondary_concerns": "", "referral_needed": False,
            "intervention_priority": "LOW"
        }
    
    # Generate Excel
    filename = f"child_{child.child_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
    filepath = os.path.join(EXPORT_DIR, filename)
    
    ExcelService.export_child_assessment(assessment_data, filepath)
    
    # Read and return file
    with open(filepath, "rb") as f:
        file_content = f.read()
    
    return Response(
        content=file_content,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )


@router.post("/session/{session_id}/excel")
def export_session_excel(
    session_id: int,
    current_user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    """Export session data as Excel"""
    session = db.query(ScreeningSession).filter(
        ScreeningSession.session_id == session_id
    ).first()
    
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    # Use same export logic but with specific session
    return export_child_excel(session.child_id, current_user_id, db)


@router.post("/bulk/excel")
def export_bulk_excel(
    child_ids: list,
    current_user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    """Export multiple children's data as a single Excel with summary"""
    if not child_ids:
        raise HTTPException(status_code=400, detail="No child IDs provided")
    
    children_data = []
    
    for child_id in child_ids:
        child = db.query(Child).filter(Child.child_id == child_id).first()
        if not child:
            continue
        
        session = db.query(ScreeningSession).filter(
            ScreeningSession.child_id == child_id,
            ScreeningSession.status == 'completed'
        ).order_by(ScreeningSession.created_at.desc()).first()
        
        if not session:
            continue
        
        # Build data for this child (simplified for bulk export)
        child_data = {
            "child_id": child.child_id,
            "child_unique_id": child.child_unique_id if hasattr(child, 'child_unique_id') else f"CHILD_{child.child_id}",
            "gender": child.gender,
            "child_age_months": session.child_age_months,
            "assessment_date": session.assessment_date.strftime("%Y-%m-%d") if session.assessment_date else "",
            "developmental": {},
            "risk": {},
            "neuro_behavioral": {},
            "nutrition": {},
            "baseline_risk": {}
        }
        
        if session.developmental_assessment:
            dev = session.developmental_assessment
            child_data["developmental"] = {
                "gm_dq": float(dev.gm_dq) if dev.gm_dq else 0,
                "fm_dq": float(dev.fm_dq) if dev.fm_dq else 0,
                "lc_dq": float(dev.lc_dq) if dev.lc_dq else 0,
                "cog_dq": float(dev.cog_dq) if dev.cog_dq else 0,
                "se_dq": float(dev.se_dq) if dev.se_dq else 0,
                "composite_dq": float(dev.composite_dq) if dev.composite_dq else 0,
            }
        
        if session.developmental_risk:
            risk = session.developmental_risk
            child_data["risk"] = {
                "num_delays": risk.num_delays
            }
        
        if session.neuro_behavioral:
            neuro = session.neuro_behavioral
            child_data["neuro_behavioral"] = {
                "autism_risk": neuro.autism_risk or "Low",
                "behavior_risk": neuro.behavior_risk or "Low"
            }
        
        if session.nutrition_assessment:
            nut = session.nutrition_assessment
            child_data["nutrition"] = {
                "nutrition_risk": nut.nutrition_risk or "Low"
            }
        
        if session.baseline_risk:
            baseline = session.baseline_risk
            child_data["baseline_risk"] = {
                "overall_risk_category": baseline.overall_risk_category or "LOW",
                "referral_needed": baseline.referral_needed or False,
                "intervention_priority": baseline.intervention_priority or "LOW"
            }
        
        children_data.append(child_data)
    
    if not children_data:
        raise HTTPException(status_code=404, detail="No valid assessment data found for provided children")
    
    # Generate bulk Excel
    filename = f"bulk_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
    filepath = os.path.join(EXPORT_DIR, filename)
    
    ExcelService.export_bulk_assessment(children_data, filepath)
    
    with open(filepath, "rb") as f:
        file_content = f.read()
    
    return Response(
        content=file_content,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )
