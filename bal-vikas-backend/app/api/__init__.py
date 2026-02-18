from fastapi import APIRouter
from . import auth, children, screening, questionnaires, interventions, export

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(children.router, prefix="/children", tags=["Children"])
api_router.include_router(screening.router, prefix="/screening", tags=["Screening"])
api_router.include_router(questionnaires.router, prefix="/questionnaires", tags=["Questionnaires"])
api_router.include_router(interventions.router, prefix="/interventions", tags=["Interventions"])
api_router.include_router(export.router, prefix="/export", tags=["Export"])
