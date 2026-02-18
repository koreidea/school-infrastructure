from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import Optional
from pydantic import BaseModel
import os
import uuid

from app.database import get_db
from app.models import User, Role
from app.schemas import UserCreate, UserResponse, UserLogin, Token
from app.services.auth_service import AuthService

router = APIRouter()
security = HTTPBearer()

# In-memory OTP storage for demo (use Redis in production)
otp_storage = {}


class RoleUpdateRequest(BaseModel):
    role_code: str  # "PARENT" | "AWW" | "SUPERVISOR"


class RoleUpdateResponse(BaseModel):
    message: str
    user: UserResponse


class ProfileUpdateResponse(BaseModel):
    message: str
    user: UserResponse


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


@router.post("/send-otp")
def send_otp(login_data: UserLogin, db: Session = Depends(get_db)):
    """Send OTP to mobile number"""
    user = db.query(User).filter(User.mobile_number == login_data.mobile_number).first()
    
    # Generate OTP
    otp = AuthService.generate_otp()
    otp_storage[login_data.mobile_number] = otp
    
    # In production: Send SMS here
    print(f"OTP for {login_data.mobile_number}: {otp}")
    
    return {
        "message": "OTP sent successfully",
        "demo_otp": otp  # Only for demo
    }


@router.post("/verify-otp")
def verify_otp(data: dict, db: Session = Depends(get_db)):
    mobile_number = data.get("mobile_number")
    otp = data.get("otp")
    """Verify OTP and return JWT token"""
    stored_otp = otp_storage.get(mobile_number)
    
    if not stored_otp or stored_otp != otp:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid OTP"
        )
    
    # Get or create user
    user = db.query(User).filter(User.mobile_number == mobile_number).first()
    
    if not user:
        # Create new user WITHOUT role - role selection will be done in app
        user = User(
            mobile_number=mobile_number,
            name=f"User {mobile_number[-4:]}",
            role_id=None,  # No role assigned yet
            preferred_language="en"
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    
    # Update last login
    from datetime import datetime
    user.last_login = datetime.now()
    db.commit()
    
    # Generate token
    access_token = AuthService.create_access_token(user.user_id)
    
    # Clear OTP
    del otp_storage[mobile_number]
    
    return Token(
        access_token=access_token,
        user=UserResponse(
            user_id=user.user_id,
            mobile_number=user.mobile_number,
            name=user.name,
            role_id=user.role_id,
            role_name=user.role.role_name if user.role else None,
            role_code=user.role.role_code if user.role else None,
            anganwadi_center_id=user.anganwadi_center_id,
            preferred_language=user.preferred_language,
            is_active=user.is_active,
            created_at=user.created_at
        )
    )


@router.post("/update-role", response_model=RoleUpdateResponse)
def update_user_role(
    role_data: RoleUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user role after login (role selection)"""
    # Validate role code
    valid_roles = ["PARENT", "AWW", "SUPERVISOR", "ADMIN"]
    if role_data.role_code not in valid_roles:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid role code. Must be one of: {', '.join(valid_roles)}"
        )
    
    # Find or create role
    role = db.query(Role).filter(Role.role_code == role_data.role_code).first()
    if not role:
        role_name_map = {
            "PARENT": "Parent/Caregiver",
            "AWW": "Anganwadi Worker",
            "SUPERVISOR": "Supervisor",
            "ADMIN": "Administrator"
        }
        role = Role(
            role_name=role_name_map.get(role_data.role_code, role_data.role_code),
            role_code=role_data.role_code
        )
        db.add(role)
        db.commit()
        db.refresh(role)
    
    # Update user's role
    current_user.role_id = role.role_id
    db.commit()
    db.refresh(current_user)
    
    return RoleUpdateResponse(
        message="Role updated successfully",
        user=UserResponse(
            user_id=current_user.user_id,
            mobile_number=current_user.mobile_number,
            name=current_user.name,
            role_id=current_user.role_id,
            role_name=current_user.role.role_name if current_user.role else None,
            role_code=current_user.role.role_code if current_user.role else None,
            anganwadi_center_id=current_user.anganwadi_center_id,
            preferred_language=current_user.preferred_language,
            is_active=current_user.is_active,
            created_at=current_user.created_at
        )
    )


@router.get("/profile")
def get_profile(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """Get current user profile"""
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
    
    return UserResponse(
        user_id=user.user_id,
        mobile_number=user.mobile_number,
        name=user.name,
        role_id=user.role_id,
        role_name=user.role.role_name if user.role else None,
        role_code=user.role.role_code if user.role else None,
        anganwadi_center_id=user.anganwadi_center_id,
        preferred_language=user.preferred_language,
        is_active=user.is_active,
        created_at=user.created_at
    )


@router.put("/profile", response_model=ProfileUpdateResponse)
async def update_profile(
    name: Optional[str] = Form(None),
    email: Optional[str] = Form(None),
    profile_photo: Optional[UploadFile] = File(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user profile (name, email, photo)"""
    
    # Update name if provided
    if name is not None and name.strip():
        current_user.name = name.strip()
    
    # Update email if provided
    if email is not None:
        current_user.email = email.strip() if email.strip() else None
    
    # Handle profile photo upload
    if profile_photo is not None:
        # Create uploads directory if it doesn't exist
        upload_dir = os.path.join("uploads", "profile_photos")
        os.makedirs(upload_dir, exist_ok=True)
        
        # Generate unique filename
        file_ext = os.path.splitext(profile_photo.filename)[1] or ".jpg"
        filename = f"{current_user.user_id}_{uuid.uuid4().hex[:8]}{file_ext}"
        file_path = os.path.join(upload_dir, filename)
        
        # Save the file
        with open(file_path, "wb") as f:
            content = await profile_photo.read()
            f.write(content)
        
        # Update user's profile photo URL
        current_user.profile_photo_url = f"/uploads/profile_photos/{filename}"
    
    db.commit()
    db.refresh(current_user)
    
    return ProfileUpdateResponse(
        message="Profile updated successfully",
        user=UserResponse(
            user_id=current_user.user_id,
            mobile_number=current_user.mobile_number,
            name=current_user.name,
            role_id=current_user.role_id,
            role_name=current_user.role.role_name if current_user.role else None,
            role_code=current_user.role.role_code if current_user.role else None,
            anganwadi_center_id=current_user.anganwadi_center_id,
            preferred_language=current_user.preferred_language,
            is_active=current_user.is_active,
            created_at=current_user.created_at
        )
    )


@router.get("/roles")
def get_available_roles(db: Session = Depends(get_db)):
    """Get all available roles for selection"""
    roles = db.query(Role).all()
    
    if not roles:
        # Create default roles if none exist
        default_roles = [
            {"role_name": "Parent/Caregiver", "role_code": "PARENT"},
            {"role_name": "Anganwadi Worker", "role_code": "AWW"},
            {"role_name": "Supervisor", "role_code": "SUPERVISOR"},
            {"role_name": "Administrator", "role_code": "ADMIN"}
        ]
        for role_data in default_roles:
            role = Role(**role_data)
            db.add(role)
        db.commit()
        roles = db.query(Role).all()
    
    return [
        {
            "role_id": role.role_id,
            "role_name": role.role_name,
            "role_code": role.role_code
        }
        for role in roles
    ]
