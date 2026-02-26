"""Analytics API endpoints."""

from fastapi import APIRouter, HTTPException
from app.services.db import get_db

router = APIRouter()


@router.get("/district/{district_id}")
async def district_analytics(district_id: int):
    """Get analytics for a specific district."""
    db = get_db()

    # District info
    district = db.table("si_districts").select("*").eq("id", district_id).single().execute()
    if not district.data:
        raise HTTPException(status_code=404, detail="District not found")

    # Schools in district
    schools = db.table("si_schools_view").select("*").eq("district_id", district_id).execute()
    school_list = schools.data or []

    # Demand plans
    demands = db.table("si_demand_plans_view").select("*").eq("district_id", district_id).execute()
    demand_list = demands.data or []

    # Compute metrics
    total_enrolment = sum(s.get("total_enrolment", 0) or 0 for s in school_list)
    avg_enrolment = total_enrolment / max(len(school_list), 1)

    priority_dist = {}
    for s in school_list:
        level = s.get("priority_level", "UNKNOWN") or "UNKNOWN"
        priority_dist[level] = priority_dist.get(level, 0) + 1

    infra_gaps = {}
    total_physical = 0
    total_financial = 0.0
    for d in demand_list:
        itype = d.get("infra_type", "OTHER")
        infra_gaps[itype] = infra_gaps.get(itype, 0) + d.get("physical_count", 0)
        total_physical += d.get("physical_count", 0)
        total_financial += d.get("financial_amount", 0.0)

    return {
        "district_id": district_id,
        "district_name": district.data["district_name"],
        "total_schools": len(school_list),
        "total_enrolment": total_enrolment,
        "avg_enrolment": round(avg_enrolment, 1),
        "total_demand_physical": total_physical,
        "total_demand_financial": round(total_financial, 2),
        "priority_distribution": priority_dist,
        "infra_gaps": infra_gaps,
    }


@router.get("/state")
async def state_analytics():
    """Get state-level analytics summary."""
    db = get_db()

    # All schools
    schools = db.table("si_schools_view").select("*").execute()
    school_list = schools.data or []

    # All demands
    demands = db.table("si_demand_plans").select("*").execute()
    demand_list = demands.data or []

    # Districts
    districts = db.table("si_districts").select("*").execute()
    mandals = db.table("si_mandals").select("*").execute()

    total_enrolment = sum(s.get("total_enrolment", 0) or 0 for s in school_list)
    total_financial = sum(d.get("financial_amount", 0.0) for d in demand_list)

    priority_dist = {}
    for s in school_list:
        level = s.get("priority_level", "UNKNOWN") or "UNKNOWN"
        priority_dist[level] = priority_dist.get(level, 0) + 1

    infra_by_type = {}
    for d in demand_list:
        itype = d.get("infra_type", "OTHER")
        infra_by_type[itype] = infra_by_type.get(itype, 0) + d.get("physical_count", 0)

    # Top priority districts
    district_scores = {}
    for s in school_list:
        did = s.get("district_id")
        dname = s.get("district_name", "Unknown")
        if did:
            if did not in district_scores:
                district_scores[did] = {"district_name": dname, "critical": 0, "high": 0, "schools": 0}
            district_scores[did]["schools"] += 1
            level = (s.get("priority_level") or "").upper()
            if level == "CRITICAL":
                district_scores[did]["critical"] += 1
            elif level == "HIGH":
                district_scores[did]["high"] += 1

    top_districts = sorted(
        district_scores.values(),
        key=lambda x: (x["critical"], x["high"]),
        reverse=True,
    )[:10]

    return {
        "total_schools": len(school_list),
        "total_districts": len(districts.data or []),
        "total_mandals": len(mandals.data or []),
        "total_enrolment": total_enrolment,
        "total_demand_financial": round(total_financial, 2),
        "priority_distribution": priority_dist,
        "infra_demand_by_type": infra_by_type,
        "top_priority_districts": top_districts,
    }
