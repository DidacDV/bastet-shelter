from pydantic import BaseModel, ConfigDict


class TaskCreate(BaseModel):
    title: str
    description: str
    num_people: int


class TaskResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    description: str
    num_people: int
    shelter_id: int

class TaskResponseList(BaseModel):
    tasks: list[TaskResponse]

class TaskUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    num_people: int | None = None