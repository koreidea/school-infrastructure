from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean, DECIMAL, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class DevelopmentalAssessment(Base):
    __tablename__ = "developmental_assessments"
    
    assessment_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"), unique=True)
    child_id = Column(Integer, ForeignKey("children.child_id"))
    
    mode_delivery = Column(String(50))
    mode_conception = Column(String(50))
    birth_status = Column(String(50))
    consanguinity = Column(String(10))
    
    gm_dq = Column(DECIMAL(5, 2))
    fm_dq = Column(DECIMAL(5, 2))
    lc_dq = Column(DECIMAL(5, 2))
    cog_dq = Column(DECIMAL(5, 2))
    se_dq = Column(DECIMAL(5, 2))
    composite_dq = Column(DECIMAL(5, 2))
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    session = relationship("ScreeningSession", back_populates="developmental_assessment")


class DevelopmentalRisk(Base):
    __tablename__ = "developmental_risks"
    
    risk_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"), unique=True)
    child_id = Column(Integer, ForeignKey("children.child_id"))
    
    gm_delay = Column(Boolean, default=False)
    fm_delay = Column(Boolean, default=False)
    lc_delay = Column(Boolean, default=False)
    cog_delay = Column(Boolean, default=False)
    se_delay = Column(Boolean, default=False)
    num_delays = Column(Integer, default=0)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    session = relationship("ScreeningSession", back_populates="developmental_risk")


class NeuroBehavioralAssessment(Base):
    __tablename__ = "neuro_behavioral_assessments"
    
    neuro_behavioral_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"), unique=True)
    child_id = Column(Integer, ForeignKey("children.child_id"))
    
    autism_risk = Column(String(20))
    adhd_risk = Column(String(20))
    behavior_risk = Column(String(20))
    
    mchat_score = Column(Integer)
    isaa_score = Column(Integer)
    adhd_score = Column(Integer)
    sdq_total_score = Column(Integer)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    session = relationship("ScreeningSession", back_populates="neuro_behavioral")


class BehaviorIndicators(Base):
    __tablename__ = "behavior_indicators"
    
    indicator_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"), unique=True)
    child_id = Column(Integer, ForeignKey("children.child_id"))
    
    behaviour_concerns = Column(Text)
    behaviour_score = Column(Integer)
    behaviour_risk_level = Column(String(20))
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    session = relationship("ScreeningSession", back_populates="behavior_indicators")


class EnvironmentCaregiving(Base):
    __tablename__ = "environment_caregiving"
    
    environment_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"), unique=True)
    child_id = Column(Integer, ForeignKey("children.child_id"))
    
    parent_child_interaction_score = Column(Integer)
    home_stimulation_score = Column(Integer)
    play_materials = Column(Boolean)
    caregiver_engagement = Column(String(20))
    language_exposure = Column(String(20))
    safe_water = Column(Boolean)
    toilet_facility = Column(Boolean)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    session = relationship("ScreeningSession", back_populates="environment_caregiving")


class NutritionAssessment(Base):
    __tablename__ = "nutrition_assessments"
    
    nutrition_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"), unique=True)
    child_id = Column(Integer, ForeignKey("children.child_id"))
    
    height_cm = Column(DECIMAL(5, 2))
    weight_kg = Column(DECIMAL(5, 2))
    head_circumference_cm = Column(DECIMAL(5, 2))
    
    height_z_score = Column(DECIMAL(5, 2))
    weight_z_score = Column(DECIMAL(5, 2))
    wfh_z_score = Column(DECIMAL(5, 2))
    
    underweight = Column(Integer, default=0)
    stunting = Column(Integer, default=0)
    wasting = Column(Integer, default=0)
    anemia = Column(Integer, default=0)
    
    nutrition_score = Column(Integer)
    nutrition_risk = Column(String(20))
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    session = relationship("ScreeningSession", back_populates="nutrition_assessment")


class BaselineRiskOutput(Base):
    __tablename__ = "baseline_risk_outputs"
    
    baseline_risk_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"), unique=True)
    child_id = Column(Integer, ForeignKey("children.child_id"))
    
    overall_risk_category = Column(String(20))
    primary_concern = Column(Text)
    secondary_concerns = Column(Text)
    referral_needed = Column(Boolean, default=False)
    intervention_priority = Column(String(20))
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    session = relationship("ScreeningSession", back_populates="baseline_risk")
