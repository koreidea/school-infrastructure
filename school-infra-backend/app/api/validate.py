"""Demand plan validation API endpoints."""

from fastapi import APIRouter, HTTPException
from app.models.schemas import DemandValidationRequest, DemandValidationResponse, ValidationResult
from app.services.validation_service import validate_demand_plans, get_all_demand_plans
from app.services.db import get_db

router = APIRouter()


@router.post("/demand-plan", response_model=DemandValidationResponse)
async def validate_demands(req: DemandValidationRequest):
    """Validate demand plans using ML + rules."""
    try:
        demands = [d.model_dump() for d in req.demands]
        results = validate_demand_plans(demands)

        validation_results = [ValidationResult(**r) for r in results]
        total_flagged = sum(1 for r in results if r["validation_status"] == "FLAGGED")
        total_approved = sum(1 for r in results if r["validation_status"] == "APPROVED")

        # Update validation status in DB
        db = get_db()
        for r in results:
            db.table("si_demand_plans") \
                .update({
                    "validation_status": r["validation_status"],
                    "validation_score": r["confidence"],
                    "validation_flags": r["reasons"],
                }) \
                .eq("school_id", r["school_id"]) \
                .eq("infra_type", r["infra_type"]) \
                .execute()

        return DemandValidationResponse(
            results=validation_results,
            total_flagged=total_flagged,
            total_approved=total_approved,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/batch")
async def batch_validate():
    """Validate all pending demand plans."""
    try:
        db = get_db()
        pending = db.table("si_demand_plans_view") \
            .select("*") \
            .eq("validation_status", "PENDING") \
            .execute()

        if not pending.data:
            return {"message": "No pending demand plans", "total_processed": 0}

        demands = [{
            "school_id": d["school_id"],
            "infra_type": d["infra_type"],
            "physical_count": d["physical_count"],
            "financial_amount": d["financial_amount"],
            "school_category": d.get("school_category"),
            "total_enrolment": None,
        } for d in pending.data]

        results = validate_demand_plans(demands)

        # Update DB
        for r, orig in zip(results, pending.data):
            db.table("si_demand_plans") \
                .update({
                    "validation_status": r["validation_status"],
                    "validation_score": r["confidence"],
                    "validation_flags": r["reasons"],
                }) \
                .eq("id", orig["id"]) \
                .execute()

        return {
            "total_processed": len(results),
            "approved": sum(1 for r in results if r["validation_status"] == "APPROVED"),
            "flagged": sum(1 for r in results if r["validation_status"] == "FLAGGED"),
            "rejected": sum(1 for r in results if r["validation_status"] == "REJECTED"),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
