from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
from datetime import datetime
import os
import shutil

from app.database import get_db
from app.models import (
    ScreeningSession, ScreeningResponse, ScreeningVideo, Child, User,
    DevelopmentalAssessment, DevelopmentalRisk, NeuroBehavioralAssessment,
    BehaviorIndicators, EnvironmentCaregiving, NutritionAssessment, BaselineRiskOutput
)
from app.schemas import (
    ScreeningSessionCreate, ScreeningSessionResponse,
    ScreeningResponseCreate, ScreeningResponseResponse, VideoUploadResponse,
    AssessmentResultResponse
)
from app.services.auth_service import AuthService
from app.services.calculation_service import CalculationService
from app.services.excel_service import ExcelService

router = APIRouter()
security = HTTPBearer()

UPLOAD_DIR = "uploads/videos"
os.makedirs(UPLOAD_DIR, exist_ok=True)


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    token = credentials.credentials
    user_id = AuthService.verify_token(token)
    
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )
    
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return user


@router.post("/start", response_model=ScreeningSessionResponse)
def start_screening(
    session_data: ScreeningSessionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Start a new screening session"""
    # Verify child exists
    child = db.query(Child).filter(Child.child_id == session_data.child_id).first()
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
    session = ScreeningSession(
        child_id=session_data.child_id,
        conducted_by_user_id=current_user.user_id,
        assessment_date=session_data.assessment_date,
        child_age_months=session_data.child_age_months,
        questionnaire_version_id=session_data.questionnaire_version_id,
        status='in_progress'
    )
    
    db.add(session)
    db.commit()
    db.refresh(session)
    
    return ScreeningSessionResponse(
        session_id=session.session_id,
        child_id=session.child_id,
        conducted_by_user_id=session.conducted_by_user_id,
        assessment_date=session.assessment_date,
        child_age_months=session.child_age_months,
        status=session.status,
        created_at=session.created_at,
        completed_at=session.completed_at
    )


@router.post("/{session_id}/responses", response_model=ScreeningResponseResponse)
def save_response(
    session_id: int,
    response_data: ScreeningResponseCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Save a screening response"""
    session = db.query(ScreeningSession).filter(ScreeningSession.session_id == session_id).first()
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found"
        )
    
    response = ScreeningResponse(
        session_id=session_id,
        assessment_type=response_data.assessment_type,
        question_id=response_data.question_id,
        question_text=response_data.question_text,
        response_value=response_data.response_value,
        response_score=response_data.response_score,
        notes=response_data.notes
    )
    
    db.add(response)
    db.commit()
    db.refresh(response)
    
    return ScreeningResponseResponse(
        response_id=response.response_id,
        session_id=response.session_id,
        assessment_type=response.assessment_type,
        question_id=response.question_id,
        question_text=response.question_text,
        response_value=response.response_value,
        response_score=response.response_score,
        notes=response.notes,
        created_at=response.created_at
    )


@router.post("/{session_id}/responses/batch")
def save_responses_batch(
    session_id: int,
    responses: List[ScreeningResponseCreate],
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Save multiple screening responses at once"""
    session = db.query(ScreeningSession).filter(ScreeningSession.session_id == session_id).first()
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found"
        )
    
    saved_responses = []
    for response_data in responses:
        response = ScreeningResponse(
            session_id=session_id,
            assessment_type=response_data.assessment_type,
            question_id=response_data.question_id,
            question_text=response_data.question_text,
            response_value=response_data.response_value,
            response_score=response_data.response_score,
            notes=response_data.notes
        )
        db.add(response)
        saved_responses.append(response)
    
    db.commit()
    
    return {
        "message": f"{len(saved_responses)} responses saved successfully",
        "session_id": session_id,
        "saved_count": len(saved_responses)
    }


@router.post("/{session_id}/video", response_model=VideoUploadResponse)
def upload_video(
    session_id: int,
    video_type: Optional[str] = None,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload a video for screening"""
    session = db.query(ScreeningSession).filter(ScreeningSession.session_id == session_id).first()
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found"
        )
    
    # Save file
    file_ext = os.path.splitext(file.filename)[1]
    file_name = f"session_{session_id}_{video_type or 'general'}_{datetime.now().strftime('%Y%m%d%H%M%S')}{file_ext}"
    file_path = os.path.join(UPLOAD_DIR, file_name)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    file_size_mb = round(os.path.getsize(file_path) / (1024 * 1024), 2)
    
    video = ScreeningVideo(
        session_id=session_id,
        video_type=video_type,
        file_path=file_path,
        file_size_mb=file_size_mb
    )
    
    db.add(video)
    db.commit()
    db.refresh(video)
    
    return VideoUploadResponse(
        video_id=video.video_id,
        session_id=video.session_id,
        video_type=video.video_type,
        file_path=video.file_path,
        file_size_mb=float(video.file_size_mb) if video.file_size_mb else None,
        uploaded_at=video.uploaded_at
    )


@router.post("/{session_id}/complete")
def complete_screening(
    session_id: int,
    measurements: Dict[str, Any],
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Complete screening and calculate all scores"""
    session = db.query(ScreeningSession).filter(ScreeningSession.session_id == session_id).first()
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found"
        )
    
    child = session.child
    calc = CalculationService()
    
    # Get all responses
    responses = db.query(ScreeningResponse).filter(
        ScreeningResponse.session_id == session_id
    ).all()
    
    # Organize responses by assessment type
    domain_responses = {
        'gm': {},
        'fm': {},
        'lc': {},
        'cog': {},
        'se': {}
    }
    
    mchat_responses = {}
    rbsk_responses = {}
    sdq_responses = {}
    environment_responses = {}
    
    for resp in responses:
        qid = resp.question_id.lower()
        resp_value = resp.response_value.lower() == 'true' if resp.response_value else False
        
        # Developmental domain responses
        if 'gm_' in qid or 'gross' in qid:
            domain_responses['gm'][resp.question_id] = resp_value
        elif 'fm_' in qid or 'fine' in qid:
            domain_responses['fm'][resp.question_id] = resp_value
        elif 'lc_' in qid or 'language' in qid:
            domain_responses['lc'][resp.question_id] = resp_value
        elif 'cog_' in qid or 'cognitive' in qid:
            domain_responses['cog'][resp.question_id] = resp_value
        elif 'se_' in qid or 'social' in qid or 'emotional' in qid:
            domain_responses['se'][resp.question_id] = resp_value
        # MCHAT responses
        elif 'mchat_' in qid:
            mchat_responses[int(qid.replace('mchat_', ''))] = resp_value
        # RBSK responses
        elif 'rbsk_' in qid:
            rbsk_responses[qid] = resp_value
        # SDQ responses
        elif 'sdq_' in qid:
            sdq_responses[qid] = resp.response_score or 0
        # Environment responses
        elif 'env_' in qid:
            environment_responses[qid] = resp_value
    
    # Calculate Developmental Quotients (DQ)
    milestones = [
        {'age_months': i, 'question_id': f'q_{i}'} for i in range(2, session.child_age_months + 1)
    ]
    
    gm_dq = calc.calculate_domain_dq(session.child_age_months, milestones, domain_responses['gm'])
    fm_dq = calc.calculate_domain_dq(session.child_age_months, milestones, domain_responses['fm'])
    lc_dq = calc.calculate_domain_dq(session.child_age_months, milestones, domain_responses['lc'])
    cog_dq = calc.calculate_domain_dq(session.child_age_months, milestones, domain_responses['cog'])
    se_dq = calc.calculate_domain_dq(session.child_age_months, milestones, domain_responses['se'])
    
    composite_dq = calc.calculate_composite_dq({
        'gm_dq': gm_dq, 'fm_dq': fm_dq, 'lc_dq': lc_dq,
        'cog_dq': cog_dq, 'se_dq': se_dq
    })
    
    # Check delays
    gm_delay = calc.is_delayed(gm_dq)
    fm_delay = calc.is_delayed(fm_dq)
    lc_delay = calc.is_delayed(lc_dq)
    cog_delay = calc.is_delayed(cog_dq)
    se_delay = calc.is_delayed(se_dq)
    num_delays = sum([gm_delay, fm_delay, lc_delay, cog_delay, se_delay])
    
    # Calculate M-CHAT risk if age appropriate (16-30 months)
    autism_risk = "Low"
    mchat_score = None
    if 16 <= session.child_age_months <= 30 and mchat_responses:
        autism_risk = calc.calculate_mchat_risk(mchat_responses)
        # Calculate M-CHAT score (number of failed items)
        mchat_score = sum(1 for v in mchat_responses.values() if v)
    
    # Calculate RBSK findings if age appropriate (36-72 months)
    rbsk_findings = []
    if 36 <= session.child_age_months <= 72 and rbsk_responses:
        rbsk_findings = [qid for qid, value in rbsk_responses.items() if value]
    
    # Calculate SDQ scores if age appropriate (36-72 months)
    sdq_scores = {}
    behavior_risk = "Low"
    sdq_total = None
    if 36 <= session.child_age_months <= 72 and sdq_responses:
        sdq_scores = calc.calculate_sdq_scores(sdq_responses)
        behavior_risk = sdq_scores.get('risk_level', 'Low')
        sdq_total = sdq_scores.get('total_difficulties', 0)
    
    # Calculate Environment & Caregiving score
    environment_score = calc.calculate_environment_score(environment_responses)
    
    # Calculate nutrition
    height = measurements.get('height_cm', 0)
    weight = measurements.get('weight_kg', 0)
    head_circumference = measurements.get('head_circumference_cm', 0)
    anemia = measurements.get('anemia', 0)
    
    height_z = calc.calculate_z_score('hfa', child.gender, session.child_age_months, height) if height else 0
    weight_z = calc.calculate_z_score('wfa', child.gender, session.child_age_months, weight) if weight else 0
    
    underweight = calc.classify_underweight(weight_z)
    stunting = calc.classify_stunting(height_z)
    wasting = measurements.get('wasting', 0)  # Would need weight-for-height calculation
    
    nutrition_score = calc.calculate_nutrition_score(underweight, stunting, wasting, anemia)
    nutrition_risk = calc.classify_nutrition_risk(nutrition_score)
    
    # Calculate overall risk
    overall_risk = calc.classify_overall_risk(num_delays, autism_risk, behavior_risk, nutrition_risk)
    referral_needed = calc.needs_referral(overall_risk)
    intervention_priority = calc.get_intervention_priority(overall_risk)
    
    # Get birth history from measurements if provided
    mode_delivery = measurements.get('mode_delivery', '')
    mode_conception = measurements.get('mode_conception', '')
    birth_status = measurements.get('birth_status', '')
    consanguinity = measurements.get('consanguinity', '')
    
    # Save assessments
    dev_assessment = DevelopmentalAssessment(
        session_id=session_id,
        child_id=child.child_id,
        mode_delivery=mode_delivery,
        mode_conception=mode_conception,
        birth_status=birth_status,
        consanguinity=consanguinity,
        gm_dq=gm_dq, fm_dq=fm_dq, lc_dq=lc_dq, cog_dq=cog_dq, se_dq=se_dq,
        composite_dq=composite_dq
    )
    db.add(dev_assessment)
    
    dev_risk = DevelopmentalRisk(
        session_id=session_id,
        child_id=child.child_id,
        gm_delay=gm_delay, fm_delay=fm_delay, lc_delay=lc_delay,
        cog_delay=cog_delay, se_delay=se_delay, num_delays=num_delays
    )
    db.add(dev_risk)
    
    neuro_assessment = NeuroBehavioralAssessment(
        session_id=session_id,
        child_id=child.child_id,
        autism_risk=autism_risk,
        adhd_risk="Low",  # Would calculate separately if needed
        behavior_risk=behavior_risk,
        mchat_score=mchat_score,
        isaa_score=None,
        adhd_score=None,
        sdq_total_score=sdq_total
    )
    db.add(neuro_assessment)
    
    behavior = BehaviorIndicators(
        session_id=session_id,
        child_id=child.child_id,
        behaviour_concerns=measurements.get('behavior_concerns', ''),
        behaviour_score=sdq_total,
        behaviour_risk_level=behavior_risk
    )
    db.add(behavior)
    
    # Environment & Caregiving assessment
    environment = EnvironmentCaregiving(
        session_id=session_id,
        child_id=child.child_id,
        parent_child_interaction_score=environment_score.get('parent_child_interaction', 0),
        home_stimulation_score=environment_score.get('home_stimulation', 0),
        play_materials=environment_responses.get('env_5', False),
        caregiver_engagement=environment_score.get('caregiver_engagement_level', 'Low'),
        language_exposure=environment_score.get('language_exposure_level', 'Low'),
        safe_water=environment_responses.get('env_13', False),
        toilet_facility=environment_responses.get('env_14', False)
    )
    db.add(environment)
    
    nutrition = NutritionAssessment(
        session_id=session_id,
        child_id=child.child_id,
        height_cm=height,
        weight_kg=weight,
        head_circumference_cm=head_circumference,
        height_z_score=height_z,
        weight_z_score=weight_z,
        wfh_z_score=0,  # Would calculate
        underweight=underweight,
        stunting=stunting,
        wasting=wasting,
        anemia=anemia,
        nutrition_score=nutrition_score,
        nutrition_risk=nutrition_risk
    )
    db.add(nutrition)
    
    # Determine primary and secondary concerns
    primary_concern = ""
    secondary_concerns = []
    
    if num_delays > 0:
        primary_concern = "Developmental delay"
        delayed_domains = []
        if gm_delay:
            delayed_domains.append("Gross Motor")
        if fm_delay:
            delayed_domains.append("Fine Motor")
        if lc_delay:
            delayed_domains.append("Language")
        if cog_delay:
            delayed_domains.append("Cognitive")
        if se_delay:
            delayed_domains.append("Social-Emotional")
        if len(delayed_domains) > 1:
            secondary_concerns.append(f"Delayed in: {', '.join(delayed_domains)}")
    
    if autism_risk in ["High", "Medium"]:
        if not primary_concern:
            primary_concern = "Autism risk"
        else:
            secondary_concerns.append(f"Autism risk: {autism_risk}")
    
    if behavior_risk in ["High", "Medium"]:
        if not primary_concern:
            primary_concern = "Behavioral concerns"
        else:
            secondary_concerns.append(f"Behavior risk: {behavior_risk}")
    
    if nutrition_risk == "High":
        if not primary_concern:
            primary_concern = "Nutritional concerns"
        else:
            secondary_concerns.append(f"Nutrition risk: {nutrition_risk}")
    
    if not primary_concern:
        primary_concern = "Normal development"
    
    baseline = BaselineRiskOutput(
        session_id=session_id,
        child_id=child.child_id,
        overall_risk_category=overall_risk,
        primary_concern=primary_concern,
        secondary_concerns="; ".join(secondary_concerns) if secondary_concerns else "",
        referral_needed=referral_needed,
        intervention_priority=intervention_priority
    )
    db.add(baseline)
    
    # Update session
    session.status = 'completed'
    session.completed_at = datetime.now()
    db.commit()
    
    return {
        "message": "Screening completed successfully",
        "session_id": session_id,
        "results": {
            "developmental": {
                "gm_dq": gm_dq,
                "fm_dq": fm_dq,
                "lc_dq": lc_dq,
                "cog_dq": cog_dq,
                "se_dq": se_dq,
                "composite_dq": composite_dq,
                "num_delays": num_delays
            },
            "neuro_behavioral": {
                "autism_risk": autism_risk,
                "mchat_score": mchat_score,
                "behavior_risk": behavior_risk,
                "sdq_total": sdq_total
            },
            "rbsk_findings": rbsk_findings,
            "environment": {
                "score": environment_score.get('total', 0),
                "max_score": environment_score.get('max', 25),
                "percentage": environment_score.get('percentage', 0)
            },
            "nutrition": {
                "height_z": height_z,
                "weight_z": weight_z,
                "nutrition_risk": nutrition_risk
            },
            "baseline_risk": {
                "overall_risk": overall_risk,
                "referral_needed": referral_needed,
                "intervention_priority": intervention_priority,
                "primary_concern": primary_concern,
                "secondary_concerns": secondary_concerns
            }
        }
    }


@router.get("/{session_id}")
def get_screening_details(
    session_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get screening session details with results"""
    session = db.query(ScreeningSession).filter(ScreeningSession.session_id == session_id).first()
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found"
        )
    
    responses = db.query(ScreeningResponse).filter(
        ScreeningResponse.session_id == session_id
    ).all()
    
    videos = db.query(ScreeningVideo).filter(
        ScreeningVideo.session_id == session_id
    ).all()
    
    dev_assessment = db.query(DevelopmentalAssessment).filter(
        DevelopmentalAssessment.session_id == session_id
    ).first()
    
    dev_risk = db.query(DevelopmentalRisk).filter(
        DevelopmentalRisk.session_id == session_id
    ).first()
    
    neuro = db.query(NeuroBehavioralAssessment).filter(
        NeuroBehavioralAssessment.session_id == session_id
    ).first()
    
    behavior = db.query(BehaviorIndicators).filter(
        BehaviorIndicators.session_id == session_id
    ).first()
    
    environment = db.query(EnvironmentCaregiving).filter(
        EnvironmentCaregiving.session_id == session_id
    ).first()
    
    nutrition = db.query(NutritionAssessment).filter(
        NutritionAssessment.session_id == session_id
    ).first()
    
    baseline = db.query(BaselineRiskOutput).filter(
        BaselineRiskOutput.session_id == session_id
    ).first()
    
    return {
        "session": {
            "session_id": session.session_id,
            "child_id": session.child_id,
            "assessment_date": session.assessment_date,
            "child_age_months": session.child_age_months,
            "status": session.status,
            "created_at": session.created_at
        },
        "responses": [
            {
                "response_id": r.response_id,
                "assessment_type": r.assessment_type,
                "question_id": r.question_id,
                "response_value": r.response_value,
                "response_score": r.response_score
            } for r in responses
        ],
        "videos": [
            {
                "video_id": v.video_id,
                "video_type": v.video_type,
                "file_path": v.file_path,
                "uploaded_at": v.uploaded_at
            } for v in videos
        ],
        "assessment": {
            "developmental": {
                "gm_dq": float(dev_assessment.gm_dq) if dev_assessment else None,
                "fm_dq": float(dev_assessment.fm_dq) if dev_assessment else None,
                "lc_dq": float(dev_assessment.lc_dq) if dev_assessment else None,
                "cog_dq": float(dev_assessment.cog_dq) if dev_assessment else None,
                "se_dq": float(dev_assessment.se_dq) if dev_assessment else None,
                "composite_dq": float(dev_assessment.composite_dq) if dev_assessment else None,
                "mode_delivery": dev_assessment.mode_delivery if dev_assessment else None,
                "birth_status": dev_assessment.birth_status if dev_assessment else None,
            } if dev_assessment else None,
            "risk": {
                "gm_delay": dev_risk.gm_delay if dev_risk else False,
                "fm_delay": dev_risk.fm_delay if dev_risk else False,
                "lc_delay": dev_risk.lc_delay if dev_risk else False,
                "cog_delay": dev_risk.cog_delay if dev_risk else False,
                "se_delay": dev_risk.se_delay if dev_risk else False,
                "num_delays": dev_risk.num_delays if dev_risk else 0,
            } if dev_risk else None,
            "neuro_behavioral": {
                "autism_risk": neuro.autism_risk if neuro else None,
                "adhd_risk": neuro.adhd_risk if neuro else None,
                "behavior_risk": neuro.behavior_risk if neuro else None,
                "mchat_score": neuro.mchat_score if neuro else None,
                "sdq_total_score": neuro.sdq_total_score if neuro else None,
            } if neuro else None,
            "behavior": {
                "concerns": behavior.behaviour_concerns if behavior else None,
                "score": behavior.behaviour_score if behavior else None,
                "risk_level": behavior.behaviour_risk_level if behavior else None,
            } if behavior else None,
            "environment": {
                "parent_child_interaction_score": environment.parent_child_interaction_score if environment else None,
                "home_stimulation_score": environment.home_stimulation_score if environment else None,
                "play_materials": environment.play_materials if environment else False,
                "caregiver_engagement": environment.caregiver_engagement if environment else None,
                "language_exposure": environment.language_exposure if environment else None,
                "safe_water": environment.safe_water if environment else False,
                "toilet_facility": environment.toilet_facility if environment else False,
            } if environment else None,
            "nutrition": {
                "height_cm": float(nutrition.height_cm) if nutrition else None,
                "weight_kg": float(nutrition.weight_kg) if nutrition else None,
                "head_circumference_cm": float(nutrition.head_circumference_cm) if nutrition else None,
                "height_z_score": float(nutrition.height_z_score) if nutrition else None,
                "weight_z_score": float(nutrition.weight_z_score) if nutrition else None,
                "nutrition_risk": nutrition.nutrition_risk if nutrition else None,
                "underweight": nutrition.underweight if nutrition else 0,
                "stunting": nutrition.stunting if nutrition else 0,
                "wasting": nutrition.wasting if nutrition else 0,
                "anemia": nutrition.anemia if nutrition else 0,
            } if nutrition else None,
            "baseline_risk": {
                "overall_risk_category": baseline.overall_risk_category if baseline else None,
                "primary_concern": baseline.primary_concern if baseline else None,
                "secondary_concerns": baseline.secondary_concerns if baseline else None,
                "referral_needed": baseline.referral_needed if baseline else False,
                "intervention_priority": baseline.intervention_priority if baseline else None,
            } if baseline else None
        }
    }


@router.get("/child/{child_id}")
def get_child_screenings(
    child_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all screening sessions for a child"""
    sessions = db.query(ScreeningSession).filter(
        ScreeningSession.child_id == child_id
    ).order_by(ScreeningSession.created_at.desc()).all()
    
    return [
        {
            "session_id": s.session_id,
            "assessment_date": s.assessment_date,
            "child_age_months": s.child_age_months,
            "status": s.status,
            "created_at": s.created_at,
            "completed_at": s.completed_at
        }
        for s in sessions
    ]


@router.get("/{session_id}/export")
def export_screening_excel(
    session_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Export screening data to Excel matching ECD dataset format"""
    session = db.query(ScreeningSession).filter(ScreeningSession.session_id == session_id).first()
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found"
        )
    
    child = session.child
    dev_assessment = db.query(DevelopmentalAssessment).filter(
        DevelopmentalAssessment.session_id == session_id
    ).first()
    dev_risk = db.query(DevelopmentalRisk).filter(
        DevelopmentalRisk.session_id == session_id
    ).first()
    neuro = db.query(NeuroBehavioralAssessment).filter(
        NeuroBehavioralAssessment.session_id == session_id
    ).first()
    behavior = db.query(BehaviorIndicators).filter(
        BehaviorIndicators.session_id == session_id
    ).first()
    environment = db.query(EnvironmentCaregiving).filter(
        EnvironmentCaregiving.session_id == session_id
    ).first()
    nutrition = db.query(NutritionAssessment).filter(
        NutritionAssessment.session_id == session_id
    ).first()
    baseline = db.query(BaselineRiskOutput).filter(
        BaselineRiskOutput.session_id == session_id
    ).first()
    
    # Build assessment data for Excel export
    assessment_data = {
        "child_unique_id": child.child_unique_id if hasattr(child, 'child_unique_id') else f"CHILD_{child.child_id}",
        "child_age_months": session.child_age_months,
        "gender": child.gender,
        "anganwadi_center": child.anganwadi_center.center_name if child.anganwadi_center else "",
        "assessment_date": session.assessment_date.strftime("%Y-%m-%d") if session.assessment_date else "",
        "mode_delivery": dev_assessment.mode_delivery if dev_assessment else "",
        "mode_conception": dev_assessment.mode_conception if dev_assessment else "",
        "birth_status": dev_assessment.birth_status if dev_assessment else "",
        "consanguinity": dev_assessment.consanguinity if dev_assessment else "",
        "developmental": {
            "gm_dq": float(dev_assessment.gm_dq) if dev_assessment and dev_assessment.gm_dq else 0,
            "fm_dq": float(dev_assessment.fm_dq) if dev_assessment and dev_assessment.fm_dq else 0,
            "lc_dq": float(dev_assessment.lc_dq) if dev_assessment and dev_assessment.lc_dq else 0,
            "cog_dq": float(dev_assessment.cog_dq) if dev_assessment and dev_assessment.cog_dq else 0,
            "se_dq": float(dev_assessment.se_dq) if dev_assessment and dev_assessment.se_dq else 0,
            "composite_dq": float(dev_assessment.composite_dq) if dev_assessment and dev_assessment.composite_dq else 0,
        },
        "risk": {
            "gm_delay": dev_risk.gm_delay if dev_risk else False,
            "fm_delay": dev_risk.fm_delay if dev_risk else False,
            "lc_delay": dev_risk.lc_delay if dev_risk else False,
            "cog_delay": dev_risk.cog_delay if dev_risk else False,
            "se_delay": dev_risk.se_delay if dev_risk else False,
            "num_delays": dev_risk.num_delays if dev_risk else 0,
        },
        "neuro_behavioral": {
            "autism_risk": neuro.autism_risk if neuro else "Low",
            "adhd_risk": neuro.adhd_risk if neuro else "Low",
            "behavior_risk": neuro.behavior_risk if neuro else "Low",
        },
        "behavior": {
            "concerns": behavior.behaviour_concerns if behavior else "",
            "score": behavior.behaviour_score if behavior else 0,
            "risk_level": behavior.behaviour_risk_level if behavior else "Low",
        },
        "environment": {
            "parent_child_interaction_score": environment.parent_child_interaction_score if environment else 0,
            "home_stimulation_score": environment.home_stimulation_score if environment else 0,
            "play_materials": environment.play_materials if environment else False,
            "caregiver_engagement": environment.caregiver_engagement if environment else "Low",
            "language_exposure": environment.language_exposure if environment else "Low",
            "safe_water": environment.safe_water if environment else False,
            "toilet_facility": environment.toilet_facility if environment else False,
        },
        "nutrition": {
            "height_cm": float(nutrition.height_cm) if nutrition and nutrition.height_cm else 0,
            "weight_kg": float(nutrition.weight_kg) if nutrition and nutrition.weight_kg else 0,
            "height_z_score": float(nutrition.height_z_score) if nutrition and nutrition.height_z_score else 0,
            "weight_z_score": float(nutrition.weight_z_score) if nutrition and nutrition.weight_z_score else 0,
            "underweight": nutrition.underweight if nutrition else 0,
            "stunting": nutrition.stunting if nutrition else 0,
            "wasting": nutrition.wasting if nutrition else 0,
            "anemia": nutrition.anemia if nutrition else 0,
            "nutrition_score": nutrition.nutrition_score if nutrition else 0,
            "nutrition_risk": nutrition.nutrition_risk if nutrition else "Low",
        },
        "baseline_risk": {
            "overall_risk_category": baseline.overall_risk_category if baseline else "LOW",
            "primary_concern": baseline.primary_concern if baseline else "",
            "secondary_concerns": baseline.secondary_concerns if baseline else "",
            "referral_needed": baseline.referral_needed if baseline else False,
            "intervention_priority": baseline.intervention_priority if baseline else "LOW",
        }
    }
    
    # Generate output path
    output_dir = "data/exports"
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, f"assessment_{child.child_id}_{session_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx")
    
    # Export to Excel
    file_path = ExcelService.export_child_assessment(assessment_data, output_path)
    
    return {
        "message": "Assessment exported successfully",
        "file_path": file_path,
        "download_url": f"/exports/{os.path.basename(file_path)}"
    }
