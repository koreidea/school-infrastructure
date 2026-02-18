from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from datetime import datetime

from app.database import get_db
from app.models import InterventionActivity, ChildInterventionPlan, ActivityLog, Child

router = APIRouter()


# Demo intervention activities
DEMO_ACTIVITIES = [
    {
        "activity_code": "GM_001",
        "domain": "gm",
        "age_min_months": 0,
        "age_max_months": 12,
        "risk_level": "Low",
        "activity_title": "Tummy Time Play",
        "activity_title_te": "పొట్టపై ఆడుకోవడం",
        "activity_description": "Place baby on tummy for 10-15 minutes several times a day. Use colorful toys to encourage lifting head.",
        "activity_description_te": "రోజుకు కొన్నిసార్లు 10-15 నిమిషాల పాటు బాబును పొట్టపై ఉంచండి. తల ఎత్తడానికి రంగురంగుల బొమ్మలను ఉపయోగించండి.",
        "materials_needed": "Soft mat, colorful toys",
        "duration_minutes": 15,
    },
    {
        "activity_code": "GM_002",
        "domain": "gm",
        "age_min_months": 12,
        "age_max_months": 24,
        "risk_level": "Medium",
        "activity_title": "Ball Kicking Game",
        "activity_title_te": "బంతి తన్నే ఆట",
        "activity_description": "Encourage child to kick a soft ball back and forth. Start with large balls and gradually use smaller ones.",
        "activity_description_te": "మృదువైన బంతిని ముందుకు వెనక్కి తన్నమని ప్రోత్సహించండి. పెద్ద బంతులతో ప్రారంభించి, నెమ్మదిగా చిన్నవి ఉపయోగించండి.",
        "materials_needed": "Soft balls of various sizes",
        "duration_minutes": 20,
    },
    {
        "activity_code": "FM_001",
        "domain": "fm",
        "age_min_months": 12,
        "age_max_months": 24,
        "risk_level": "Low",
        "activity_title": "Block Stacking",
        "activity_title_te": "బ్లాకులు అగ్గి పెట్టడం",
        "activity_description": "Show child how to stack blocks. Start with 2-3 blocks and increase gradually.",
        "activity_description_te": "బ్లాకులు అగ్గి పెట్టడం ఎలాగో చూపించండి. 2-3 బ్లాకులతో ప్రారంభించి, నెమ్మదిగా పెంచండి.",
        "materials_needed": "Wooden blocks",
        "duration_minutes": 15,
    },
    {
        "activity_code": "LC_001",
        "domain": "lc",
        "age_min_months": 18,
        "age_max_months": 36,
        "risk_level": "Medium",
        "activity_title": "Picture Book Reading",
        "activity_title_te": "బొమ్మల పుస్తకం చదవడం",
        "activity_description": "Read picture books daily. Point to pictures and name them. Ask child to point to objects.",
        "activity_description_te": "రోజువారీగా బొమ్మల పుస్తకాలు చదవండి. బొమ్మలను చూపించి పేర్లు చెప్పండి. వస్తువులను చూపమని అడగండి.",
        "materials_needed": "Picture books",
        "duration_minutes": 20,
    },
    {
        "activity_code": "COG_001",
        "domain": "cog",
        "age_min_months": 24,
        "age_max_months": 48,
        "risk_level": "Low",
        "activity_title": "Sorting Game",
        "activity_title_te": "వర్గీకరణ ఆట",
        "activity_description": "Sort objects by color, shape, or size. Use simple household items like spoons, blocks, or toys.",
        "activity_description_te": "రంగు, ఆకారం, పరిమాణం ప్రకారం వస్తువులను వేరు చేయండి. స్పూన్లు, బ్లాకులు లేదా బొమ్మల వంటి సాధారణ వస్తువులను ఉపయోగించండి.",
        "materials_needed": "Household items, colored objects",
        "duration_minutes": 20,
    },
    {
        "activity_code": "SE_001",
        "domain": "se",
        "age_min_months": 24,
        "age_max_months": 60,
        "risk_level": "High",
        "activity_title": "Play Date Organization",
        "activity_title_te": "స్నేహితులతో కలిసి ఆడటం",
        "activity_description": "Organize regular play dates with peers. Start with short sessions and supervise closely.",
        "activity_description_te": "సమవయస్కులతో కలిసి ఆడటానికి రోజులను నిర్ణయించండి. చిన్న సెషన్లతో ప్రారంభించి, జాగ్రత్తగా పర్యవేక్షించండి.",
        "materials_needed": "Toys for sharing",
        "duration_minutes": 30,
    },
]


@router.get("/activities")
def get_all_activities(db: Session = Depends(get_db)):
    """Get all intervention activities"""
    activities = db.query(InterventionActivity).all()
    
    if not activities:
        return DEMO_ACTIVITIES
    
    return [
        {
            "activity_id": a.activity_id,
            "activity_code": a.activity_code,
            "domain": a.domain,
            "age_min_months": a.age_min_months,
            "age_max_months": a.age_max_months,
            "risk_level": a.risk_level,
            "activity_title": a.activity_title,
            "activity_description": a.activity_description,
            "materials_needed": a.materials_needed,
            "duration_minutes": a.duration_minutes,
        }
        for a in activities
    ]


@router.get("/recommend/{child_id}")
def get_recommended_activities(child_id: int, db: Session = Depends(get_db)):
    """Get recommended activities for a child based on their assessment"""
    child = db.query(Child).filter(Child.child_id == child_id).first()
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")
    
    # Calculate age
    from datetime import date
    age_months = (date.today() - child.date_of_birth).days // 30
    
    # Get latest assessment
    from app.models import ScreeningSession, DevelopmentalRisk
    latest_session = db.query(ScreeningSession).filter(
        ScreeningSession.child_id == child_id,
        ScreeningSession.status == 'completed'
    ).order_by(ScreeningSession.created_at.desc()).first()
    
    delays = []
    if latest_session and latest_session.developmental_risk:
        risk = latest_session.developmental_risk
        if risk.gm_delay:
            delays.append('gm')
        if risk.fm_delay:
            delays.append('fm')
        if risk.lc_delay:
            delays.append('lc')
        if risk.cog_delay:
            delays.append('cog')
        if risk.se_delay:
            delays.append('se')
    
    # Filter activities
    recommended = []
    for activity in DEMO_ACTIVITIES:
        if (activity["age_min_months"] <= age_months <= activity["age_max_months"] and
            (not delays or activity["domain"] in delays)):
            recommended.append(activity)
    
    return recommended[:5]  # Return top 5


@router.post("/log")
def log_activity(log_data: Dict[str, Any], db: Session = Depends(get_db)):
    """Log a completed activity"""
    log = ActivityLog(
        child_id=log_data.get("child_id"),
        activity_id=log_data.get("activity_id"),
        completed_date=log_data.get("completed_date"),
        duration_minutes=log_data.get("duration_minutes"),
        notes=log_data.get("notes"),
        logged_by_user_id=log_data.get("logged_by_user_id")
    )
    
    db.add(log)
    db.commit()
    
    return {"message": "Activity logged successfully"}


@router.post("/seed")
def seed_activities(db: Session = Depends(get_db)):
    """Seed demo intervention activities"""
    existing = db.query(InterventionActivity).first()
    if existing:
        return {"message": "Activities already seeded"}
    
    for act in DEMO_ACTIVITIES:
        activity = InterventionActivity(
            activity_code=act["activity_code"],
            domain=act["domain"],
            age_min_months=act["age_min_months"],
            age_max_months=act["age_max_months"],
            risk_level=act["risk_level"],
            activity_title=act["activity_title"],
            activity_description=act["activity_description"],
            materials_needed=act["materials_needed"],
            duration_minutes=act["duration_minutes"]
        )
        db.add(activity)
    
    db.commit()
    return {"message": "Activities seeded successfully"}
