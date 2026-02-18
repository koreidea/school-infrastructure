from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.database import engine, Base
from app.api import api_router
from app.models import Role


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create tables
    Base.metadata.create_all(bind=engine)
    
    # Seed roles
    from app.database import SessionLocal
    db = SessionLocal()
    try:
        default_roles = [
            ("Parent/Caregiver", "PARENT"),
            ("Anganwadi Worker", "AWW"),
            ("Supervisor", "SUPERVISOR"),
            ("Admin", "ADMIN"),
        ]
        
        for role_name, role_code in default_roles:
            existing = db.query(Role).filter(Role.role_code == role_code).first()
            if not existing:
                db.add(Role(role_name=role_name, role_code=role_code))
        
        db.commit()
    finally:
        db.close()
    
    yield
    # Shutdown (if needed)


app = FastAPI(
    title="Bal Vikas API",
    description="Early Childhood Development Screening Platform",
    version="1.0.0",
    lifespan=lifespan
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(api_router, prefix="/api")


@app.get("/")
def root():
    return {
        "message": "Bal Vikas API - Early Childhood Development Platform",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
def health_check():
    return {"status": "healthy"}
