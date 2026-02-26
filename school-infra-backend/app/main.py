"""
School Infrastructure Planning — FastAPI ML Backend

Endpoints:
  POST /api/forecast/enrolment/{school_id}  — Predict next year's enrolment
  POST /api/forecast/batch                  — Batch forecast for all schools
  POST /api/validate/demand-plan            — ML-based anomaly detection
  GET  /api/analytics/district/{district_id} — District analytics
  GET  /api/analytics/state                 — State-level summary
  GET  /health                              — Health check
"""

import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

load_dotenv()

from app.api.forecast import router as forecast_router
from app.api.validate import router as validate_router
from app.api.analytics import router as analytics_router

app = FastAPI(
    title="School Infrastructure AI Backend",
    version="1.0.0",
    description="AI-powered enrolment forecasting and demand validation for school infrastructure planning",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(forecast_router, prefix="/api/forecast", tags=["Forecast"])
app.include_router(validate_router, prefix="/api/validate", tags=["Validation"])
app.include_router(analytics_router, prefix="/api/analytics", tags=["Analytics"])


@app.get("/health")
async def health():
    return {"status": "ok", "service": "school-infra-backend"}
