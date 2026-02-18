from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    mobile_number: str = Field(..., min_length=10, max_length=10)
    name: str
    preferred_language: str = "en"


class UserCreate(UserBase):
    role_id: int
    anganwadi_center_id: Optional[int] = None


class UserResponse(UserBase):
    user_id: int
    role_id: Optional[int] = None
    role_name: Optional[str] = None
    role_code: Optional[str] = None
    anganwadi_center_id: Optional[int] = None
    email: Optional[str] = None
    profile_photo_url: Optional[str] = None
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class UserLogin(BaseModel):
    mobile_number: str


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class TokenData(BaseModel):
    user_id: Optional[int] = None
