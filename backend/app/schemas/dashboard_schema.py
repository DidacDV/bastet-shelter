from pydantic import BaseModel

class ShelterDashboardResponse(BaseModel):
    animal_count: int
    volunteer_count: int
    active_adoption_count: int = 0