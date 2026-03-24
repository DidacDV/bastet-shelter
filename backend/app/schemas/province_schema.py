from pydantic import BaseModel, ConfigDict
from datetime import datetime

class ProvinceResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    community_code: str
    last_updated: datetime

