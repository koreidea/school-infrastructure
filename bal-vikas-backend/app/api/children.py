from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from app.database import get_db
from app.models import Child, User
from app.schemas import ChildCreate, ChildResponse, ChildUpdate
from app.services.auth_service import AuthService

router = APIRouter()
security = HTTPBearer()


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


@router.get("", response_model=List[ChildResponse])
def get_children(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100
):
    """Get all children for current user"""
    query = db.query(Child)
    
    # Filter by user role
    if current_user.role and current_user.role.role_code == "PARENT":
        query = query.filter(Child.parent_user_id == current_user.user_id)
    elif current_user.role and current_user.role.role_code == "AWW":
        query = query.filter(
            (Child.aww_user_id == current_user.user_id) |
            (Child.anganwadi_center_id == current_user.anganwadi_center_id)
        )
    
    children = query.offset(skip).limit(limit).all()
    
    result = []
    for child in children:
        age_months = None
        if child.date_of_birth:
            age_months = (datetime.now().date() - child.date_of_birth).days // 30
        
        result.append(ChildResponse(
            child_id=child.child_id,
            child_unique_id=child.child_unique_id,
            name=child.name,
            date_of_birth=child.date_of_birth,
            gender=child.gender,
            parent_user_id=child.parent_user_id,
            aww_user_id=child.aww_user_id,
            anganwadi_center_id=child.anganwadi_center_id,
            photo_url=child.photo_url,
            created_at=child.created_at,
            age_months=age_months
        ))
    
    return result


@router.get("/{child_id}/details")
def get_child_details(
    child_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get detailed child information with all assessments"""
    child = db.query(Child).filter(Child.child_id == child_id).first()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
    # Get latest screening session
    from app.models import ScreeningSession, DevelopmentalAssessment, DevelopmentalRisk, NutritionAssessment
    
    latest_session = db.query(ScreeningSession).filter(
        ScreeningSession.child_id == child_id
    ).order_by(ScreeningSession.created_at.desc()).first()
    
    # Default response
    response = {
        "child_id": child.child_id,
        "child_unique_id": child.child_unique_id,
        "name": child.name,
        "date_of_birth": child.date_of_birth.isoformat() if child.date_of_birth else None,
        "gender": child.gender,
        "age_months": (datetime.now().date() - child.date_of_birth).days // 30 if child.date_of_birth else None,
        "photo_url": child.photo_url,
        "overall_risk": "LOW",
        "referral_needed": False,
        "gm_dq": None,
        "fm_dq": None,
        "lc_dq": None,
        "cog_dq": None,
        "se_dq": None,
        "gm_delay": False,
        "fm_delay": False,
        "lc_delay": False,
        "cog_delay": False,
        "se_delay": False,
        "nutrition_risk": "Normal",
        "birth_weight_kg": None,
        "birth_height_cm": None,
        "caregiving_quality": "Good",
        "stimulation_score": None,
        "screenings": []
    }
    
    if latest_session:
        # Get developmental assessment
        dev_assessment = db.query(DevelopmentalAssessment).filter(
            DevelopmentalAssessment.session_id == latest_session.session_id
        ).first()
        
        if dev_assessment:
            response["gm_dq"] = dev_assessment.gm_dq
            response["fm_dq"] = dev_assessment.fm_dq
            response["lc_dq"] = dev_assessment.lc_dq
            response["cog_dq"] = dev_assessment.cog_dq
            response["se_dq"] = dev_assessment.se_dq
        
        # Get developmental risk
        dev_risk = db.query(DevelopmentalRisk).filter(
            DevelopmentalRisk.session_id == latest_session.session_id
        ).first()
        
        if dev_risk:
            response["gm_delay"] = dev_risk.gm_delay or False
            response["fm_delay"] = dev_risk.fm_delay or False
            response["lc_delay"] = dev_risk.lc_delay or False
            response["cog_delay"] = dev_risk.cog_delay or False
            response["se_delay"] = dev_risk.se_delay or False
            response["overall_risk"] = dev_risk.overall_risk_category or "LOW"
            response["referral_needed"] = dev_risk.referral_needed or False
        
        # Get nutrition assessment
        nutrition = db.query(NutritionAssessment).filter(
            NutritionAssessment.session_id == latest_session.session_id
        ).first()
        
        if nutrition:
            response["nutrition_risk"] = nutrition.nutrition_risk or "Normal"
            response["birth_weight_kg"] = nutrition.birth_weight_kg
            response["birth_height_cm"] = nutrition.birth_height_cm
    
    # Get all screenings
    sessions = db.query(ScreeningSession).filter(
        ScreeningSession.child_id == child_id
    ).order_by(ScreeningSession.created_at.desc()).all()
    
    response["screenings"] = [
        {
            "session_id": s.session_id,
            "assessment_date": s.assessment_date.isoformat() if s.assessment_date else None,
            "child_age_months": s.child_age_months,
            "status": s.status,
            "created_at": s.created_at.isoformat() if s.created_at else None,
            "completed_at": s.completed_at.isoformat() if s.completed_at else None
        }
        for s in sessions
    ]
    
    return response


@router.get("/{child_id}", response_model=ChildResponse)
def get_child(
    child_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get child by ID"""
    child = db.query(Child).filter(Child.child_id == child_id).first()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
    age_months = None
    if child.date_of_birth:
        age_months = (datetime.now().date() - child.date_of_birth).days // 30
    
    return ChildResponse(
        child_id=child.child_id,
        child_unique_id=child.child_unique_id,
        name=child.name,
        date_of_birth=child.date_of_birth,
        gender=child.gender,
        parent_user_id=child.parent_user_id,
        aww_user_id=child.aww_user_id,
        anganwadi_center_id=child.anganwadi_center_id,
        photo_url=child.photo_url,
        created_at=child.created_at,
        age_months=age_months
    )


@router.post("", response_model=ChildResponse)
def create_child(
    child_data: ChildCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Register a new child"""
    # Generate unique ID
    import uuid
    unique_id = f"CHILD-{uuid.uuid4().hex[:8].upper()}"
    
    # Set parent/AWW based on user role
    parent_id = None
    aww_id = None
    
    if current_user.role and current_user.role.role_code == "PARENT":
        parent_id = current_user.user_id
    elif current_user.role and current_user.role.role_code == "AWW":
        aww_id = current_user.user_id
    
    child = Child(
        child_unique_id=unique_id,
        name=child_data.name,
        date_of_birth=child_data.date_of_birth,
        gender=child_data.gender,
        parent_user_id=parent_id,
        aww_user_id=aww_id,
        anganwadi_center_id=current_user.anganwadi_center_id
    )
    
    db.add(child)
    db.commit()
    db.refresh(child)
    
    age_months = None
    if child.date_of_birth:
        age_months = (datetime.now().date() - child.date_of_birth).days // 30
    
    return ChildResponse(
        child_id=child.child_id,
        child_unique_id=child.child_unique_id,
        name=child.name,
        date_of_birth=child.date_of_birth,
        gender=child.gender,
        parent_user_id=child.parent_user_id,
        aww_user_id=child.aww_user_id,
        anganwadi_center_id=child.anganwadi_center_id,
        photo_url=child.photo_url,
        created_at=child.created_at,
        age_months=age_months
    )


@router.get("/{child_id}/details")
def get_child_details(
    child_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get detailed child information with all assessments"""
    child = db.query(Child).filter(Child.child_id == child_id).first()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
    # Get latest screening session
    from app.models import ScreeningSession, DevelopmentalAssessment, DevelopmentalRisk, NutritionAssessment
    
    latest_session = db.query(ScreeningSession).filter(
        ScreeningSession.child_id == child_id
    ).order_by(ScreeningSession.created_at.desc()).first()
    
    # Default response
    response = {
        "child_id": child.child_id,
        "child_unique_id": child.child_unique_id,
        "name": child.name,
        "date_of_birth": child.date_of_birth.isoformat() if child.date_of_birth else None,
        "gender": child.gender,
        "age_months": (datetime.now().date() - child.date_of_birth).days // 30 if child.date_of_birth else None,
        "photo_url": child.photo_url,
        "overall_risk": "LOW",
        "referral_needed": False,
        "gm_dq": None,
        "fm_dq": None,
        "lc_dq": None,
        "cog_dq": None,
        "se_dq": None,
        "gm_delay": False,
        "fm_delay": False,
        "lc_delay": False,
        "cog_delay": False,
        "se_delay": False,
        "nutrition_risk": "Normal",
        "birth_weight_kg": None,
        "birth_height_cm": None,
        "caregiving_quality": "Good",
        "stimulation_score": None,
        "screenings": []
    }
    
    if latest_session:
        # Get developmental assessment
        dev_assessment = db.query(DevelopmentalAssessment).filter(
            DevelopmentalAssessment.session_id == latest_session.session_id
        ).first()
        
        if dev_assessment:
            response["gm_dq"] = dev_assessment.gm_dq
            response["fm_dq"] = dev_assessment.fm_dq
            response["lc_dq"] = dev_assessment.lc_dq
            response["cog_dq"] = dev_assessment.cog_dq
            response["se_dq"] = dev_assessment.se_dq
        
        # Get developmental risk
        dev_risk = db.query(DevelopmentalRisk).filter(
            DevelopmentalRisk.session_id == latest_session.session_id
        ).first()
        
        if dev_risk:
            response["gm_delay"] = dev_risk.gm_delay or False
            response["fm_delay"] = dev_risk.fm_delay or False
            response["lc_delay"] = dev_risk.lc_delay or False
            response["cog_delay"] = dev_risk.cog_delay or False
            response["se_delay"] = dev_risk.se_delay or False
            response["overall_risk"] = dev_risk.overall_risk_category or "LOW"
            response["referral_needed"] = dev_risk.referral_needed or False
        
        # Get nutrition assessment
        nutrition = db.query(NutritionAssessment).filter(
            NutritionAssessment.session_id == latest_session.session_id
        ).first()
        
        if nutrition:
            response["nutrition_risk"] = nutrition.nutrition_risk or "Normal"
            response["birth_weight_kg"] = nutrition.birth_weight_kg
            response["birth_height_cm"] = nutrition.birth_height_cm
    
    # Get all screenings
    sessions = db.query(ScreeningSession).filter(
        ScreeningSession.child_id == child_id
    ).order_by(ScreeningSession.created_at.desc()).all()
    
    response["screenings"] = [
        {
            "session_id": s.session_id,
            "assessment_date": s.assessment_date.isoformat() if s.assessment_date else None,
            "child_age_months": s.child_age_months,
            "status": s.status,
            "created_at": s.created_at.isoformat() if s.created_at else None,
            "completed_at": s.completed_at.isoformat() if s.completed_at else None
        }
        for s in sessions
    ]
    
    return response


@router.put("/{child_id}", response_model=ChildResponse)
def update_child(
    child_id: int,
    child_data: ChildUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update child information"""
    child = db.query(Child).filter(Child.child_id == child_id).first()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
    if child_data.name:
        child.name = child_data.name
    if child_data.photo_url:
        child.photo_url = child_data.photo_url
    
    db.commit()
    db.refresh(child)
    
    age_months = None
    if child.date_of_birth:
        age_months = (datetime.now().date() - child.date_of_birth).days // 30
    
    return ChildResponse(
        child_id=child.child_id,
        child_unique_id=child.child_unique_id,
        name=child.name,
        date_of_birth=child.date_of_birth,
        gender=child.gender,
        parent_user_id=child.parent_user_id,
        aww_user_id=child.aww_user_id,
        anganwadi_center_id=child.anganwadi_center_id,
        photo_url=child.photo_url,
        created_at=child.created_at,
        age_months=age_months
    )


@router.delete("/{child_id}")
def delete_child(
    child_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Soft delete a child"""
    child = db.query(Child).filter(Child.child_id == child_id).first()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
    # Soft delete by marking inactive
    # For now, we'll actually delete
    db.delete(child)
    db.commit()
    
    return {"message": "Child deleted successfully"}
