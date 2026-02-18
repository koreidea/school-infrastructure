from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Boolean, Date
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class InterventionActivity(Base):
    __tablename__ = "intervention_activities"
    
    activity_id = Column(Integer, primary_key=True, index=True)
    activity_code = Column(String(50), unique=True)
    domain = Column(String(50))
    age_min_months = Column(Integer)
    age_max_months = Column(Integer)
    risk_level = Column(String(20))
    activity_title = Column(String(200))
    activity_description = Column(Text)
    materials_needed = Column(Text)
    duration_minutes = Column(Integer)
    demonstration_video_url = Column(Text)
    bot_deliverable = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    child_plans = relationship("ChildInterventionPlan", back_populates="activity")
    activity_logs = relationship("ActivityLog", back_populates="activity")


class ChildInterventionPlan(Base):
    __tablename__ = "child_intervention_plans"
    
    plan_id = Column(Integer, primary_key=True, index=True)
    child_id = Column(Integer, ForeignKey("children.child_id"))
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"))
    activity_id = Column(Integer, ForeignKey("intervention_activities.activity_id"))
    assigned_date = Column(Date, nullable=False)
    target_frequency = Column(String(50))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    child = relationship("Child")
    session = relationship("ScreeningSession")
    activity = relationship("InterventionActivity", back_populates="child_plans")


class ActivityLog(Base):
    __tablename__ = "activity_logs"
    
    log_id = Column(Integer, primary_key=True, index=True)
    child_id = Column(Integer, ForeignKey("children.child_id"))
    activity_id = Column(Integer, ForeignKey("intervention_activities.activity_id"))
    completed_date = Column(Date)
    duration_minutes = Column(Integer)
    notes = Column(Text)
    proof_photo_url = Column(Text)
    logged_by_user_id = Column(Integer, ForeignKey("users.user_id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    child = relationship("Child")
    activity = relationship("InterventionActivity", back_populates="activity_logs")
    logged_by = relationship("User")
