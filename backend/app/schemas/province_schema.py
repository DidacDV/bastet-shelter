from typing import List

from pydantic import BaseModel, ConfigDict
from datetime import datetime

class ProvinceResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str

class ProvinceListResponse(BaseModel):
    provinces: List[ProvinceResponse]