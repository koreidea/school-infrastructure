from sqlalchemy import Column, Integer, String, Date, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Child(Base):
    __tablename__ = "children"
    
    child_id = Column(Integer, primary_key=True, index=True)
    child_unique_id = Column(String(50), unique=True, nullable=False, index=True)
    name = Column(String(100), nullable=False)
    date_of_birth = Column(Date, nullable=False)
    gender = Column(String(10), nullable=False)
    parent_user_id = Column(Integer, ForeignKey("users.user_id"))
    aww_user_id = Column(Integer, ForeignKey("users.user_id"))
    anganwadi_center_id = Column(Integer, ForeignKey("anganwadi_centers.center_id"))
    photo_url = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    parent = relationship("User", back_populates="children", foreign_keys=[parent_user_id])
    anganwadi_center = relationship("AnganwadiCenter", back_populates="children")
    screening_sessions = relationship("ScreeningSession", back_populates="child", cascade="all, delete-orphan")
