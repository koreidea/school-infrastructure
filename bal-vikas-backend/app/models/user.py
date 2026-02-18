from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Role(Base):
    __tablename__ = "roles"
    
    role_id = Column(Integer, primary_key=True, index=True)
    role_name = Column(String(50), unique=True, nullable=False)
    role_code = Column(String(20), unique=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    users = relationship("User", back_populates="role")


class User(Base):
    __tablename__ = "users"
    
    user_id = Column(Integer, primary_key=True, index=True)
    mobile_number = Column(String(10), unique=True, nullable=False, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100), nullable=True)
    profile_photo_url = Column(String(500), nullable=True)
    role_id = Column(Integer, ForeignKey("roles.role_id"))
    anganwadi_center_id = Column(Integer, ForeignKey("anganwadi_centers.center_id"))
    preferred_language = Column(String(10), default='en')
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    last_login = Column(DateTime(timezone=True), nullable=True)
    
    role = relationship("Role", back_populates="users")
    anganwadi_center = relationship("AnganwadiCenter", back_populates="workers", foreign_keys="[User.anganwadi_center_id]")
    children = relationship("Child", back_populates="parent", foreign_keys="Child.parent_user_id")
    conducted_screenings = relationship("ScreeningSession", back_populates="conducted_by")


class AnganwadiCenter(Base):
    __tablename__ = "anganwadi_centers"
    
    center_id = Column(Integer, primary_key=True, index=True)
    center_code = Column(String(50), unique=True, nullable=False)
    center_name = Column(String(200), nullable=False)
    district = Column(String(100))
    mandal = Column(String(100))
    village = Column(String(100))
    aww_user_id = Column(Integer, ForeignKey("users.user_id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    workers = relationship("User", back_populates="anganwadi_center", foreign_keys="User.anganwadi_center_id")
    children = relationship("Child", back_populates="anganwadi_center")
