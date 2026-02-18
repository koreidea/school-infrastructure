from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime


class ChildBase(BaseModel):
    name: str
    date_of_birth: date
    gender: str


class ChildCreate(ChildBase):
    child_unique_id: Optional[str] = None
    parent_user_id: Optional[int] = None
    aww_user_id: Optional[int] = None
    anganwadi_center_id: Optional[int] = None


class ChildUpdate(BaseModel):
    name: Optional[str] = None
    photo_url: Optional[str] = None


class ChildResponse(ChildBase):
    child_id: int
    child_unique_id: str
    parent_user_id: Optional[int]
    aww_user_id: Optional[int]
    anganwadi_center_id: Optional[int]
    photo_url: Optional[str]
    created_at: datetime
    age_months: Optional[int] = None
    
    class Config:
        from_attributes = True
