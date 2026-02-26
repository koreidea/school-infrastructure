"""Enrolment forecasting API endpoints."""

from fastapi import APIRouter, HTTPException
from app.models.schemas import ForecastResponse, BatchForecastRequest
from app.services.forecast_service import forecast_school, save_forecasts
from app.services.db import get_db

router = APIRouter()


@router.post("/enrolment/{school_id}", response_model=ForecastResponse)
async def forecast_enrolment(school_id: int, years_ahead: int = 1):
    """Predict next year's enrolment for a specific school."""
    try:
        result = forecast_school(school_id, years_ahead)
        if not result["forecasts"]:
            raise HTTPException(status_code=404, detail="No enrolment data found for school")

        # Save forecasts to DB
        save_forecasts(school_id, result["forecasts"])

        return ForecastResponse(
            school_id=school_id,
            forecasts=result["forecasts"],
            overall_trend=result["overall_trend"],
            growth_rate=result["growth_rate"],
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/batch")
async def batch_forecast(req: BatchForecastRequest):
    """Run forecasting for all schools."""
    db = get_db()
    schools = db.table("si_schools").select("id").execute()

    results = []
    errors = []
    for school in schools.data:
        try:
            result = forecast_school(school["id"], req.years_ahead)
            if result["forecasts"]:
                save_forecasts(school["id"], result["forecasts"])
                results.append({
                    "school_id": school["id"],
                    "trend": result["overall_trend"],
                    "growth_rate": result["growth_rate"],
                    "forecast_count": len(result["forecasts"]),
                })
        except Exception as e:
            errors.append({"school_id": school["id"], "error": str(e)})

    return {
        "total_processed": len(results),
        "total_errors": len(errors),
        "results": results[:20],  # Return first 20
        "errors": errors[:10],
    }
