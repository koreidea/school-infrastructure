from sqlalchemy import Column, Integer, String, Date, DateTime, ForeignKey, Text, JSON, DECIMAL, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class QuestionnaireVersion(Base):
    __tablename__ = "questionnaire_versions"
    
    version_id = Column(Integer, primary_key=True, index=True)
    version_number = Column(String(20), nullable=False)
    questionnaire_data = Column(JSON, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    screening_sessions = relationship("ScreeningSession", back_populates="questionnaire_version")


class ScreeningSession(Base):
    __tablename__ = "screening_sessions"
    
    session_id = Column(Integer, primary_key=True, index=True)
    child_id = Column(Integer, ForeignKey("children.child_id"), nullable=False)
    conducted_by_user_id = Column(Integer, ForeignKey("users.user_id"))
    assessment_date = Column(Date, nullable=False)
    child_age_months = Column(Integer, nullable=False)
    questionnaire_version_id = Column(Integer, ForeignKey("questionnaire_versions.version_id"))
    status = Column(String(20), default='in_progress')
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    completed_at = Column(DateTime(timezone=True), nullable=True)
    
    child = relationship("Child", back_populates="screening_sessions")
    conducted_by = relationship("User", back_populates="conducted_screenings")
    questionnaire_version = relationship("QuestionnaireVersion", back_populates="screening_sessions")
    responses = relationship("ScreeningResponse", back_populates="session", cascade="all, delete-orphan")
    videos = relationship("ScreeningVideo", back_populates="session", cascade="all, delete-orphan")
    developmental_assessment = relationship("DevelopmentalAssessment", back_populates="session", uselist=False)
    developmental_risk = relationship("DevelopmentalRisk", back_populates="session", uselist=False)
    neuro_behavioral = relationship("NeuroBehavioralAssessment", back_populates="session", uselist=False)
    behavior_indicators = relationship("BehaviorIndicators", back_populates="session", uselist=False)
    environment_caregiving = relationship("EnvironmentCaregiving", back_populates="session", uselist=False)
    nutrition_assessment = relationship("NutritionAssessment", back_populates="session", uselist=False)
    baseline_risk = relationship("BaselineRiskOutput", back_populates="session", uselist=False)


class ScreeningResponse(Base):
    __tablename__ = "screening_responses"
    
    response_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"), nullable=False)
    assessment_type = Column(String(50), nullable=False)
    question_id = Column(String(100), nullable=False)
    question_text = Column(Text)
    response_value = Column(Text)
    response_score = Column(Integer)
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    session = relationship("ScreeningSession", back_populates="responses")


class ScreeningVideo(Base):
    __tablename__ = "screening_videos"
    
    video_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("screening_sessions.session_id"), nullable=False)
    video_type = Column(String(50))
    file_path = Column(Text, nullable=False)
    file_size_mb = Column(DECIMAL(10, 2))
    uploaded_at = Column(DateTime(timezone=True), server_default=func.now())
    
    session = relationship("ScreeningSession", back_populates="videos")
