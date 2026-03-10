from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.animal_service import AnimalService
from app.repositories.animal_repo import AnimalRepository
from app.schemas.animals_schema import AnimalResponse

router = APIRouter(prefix="/animals", tags=["animals"])

def get_animal_service(db: Session = Depends(get_db)) -> AnimalService:
    return AnimalService(AnimalRepository(), db)

@router.get("/{animal_id}", response_model=AnimalResponse)
def get_animal(animal_id: int, service: AnimalService = Depends(get_animal_service)):
    try:
        return service.get_animal(animal_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))