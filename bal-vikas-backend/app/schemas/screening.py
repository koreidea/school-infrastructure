from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import date, datetime


class ScreeningSessionCreate(BaseModel):
    child_id: int
    assessment_date: date
    child_age_months: int
    questionnaire_version_id: Optional[int] = None


class ScreeningSessionResponse(BaseModel):
    session_id: int
    child_id: int
    conducted_by_user_id: Optional[int]
    assessment_date: date
    child_age_months: int
    status: str
    created_at: datetime
    completed_at: Optional[datetime]
    
    class Config:
        from_attributes = True


class ScreeningResponseCreate(BaseModel):
    session_id: int
    assessment_type: str
    question_id: str
    question_text: Optional[str] = None
    response_value: str
    response_score: Optional[int] = None
    notes: Optional[str] = None


class ScreeningResponseResponse(ScreeningResponseCreate):
    response_id: int
    created_at: datetime
    
    class Config:
        from_attributes = True


class VideoUploadResponse(BaseModel):
    video_id: int
    session_id: int
    video_type: Optional[str]
    file_path: str
    file_size_mb: Optional[float]
    uploaded_at: datetime
    
    class Config:
        from_attributes = True


class QuestionnaireData(BaseModel):
    version_id: int
    version_number: str
    questionnaire_data: Dict[str, Any]
    is_active: bool
