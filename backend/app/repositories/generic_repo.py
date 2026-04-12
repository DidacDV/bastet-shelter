from typing import Generic, TypeVar, Type
from sqlalchemy.orm import Session

T = TypeVar('T')

class BaseRepository(Generic[T]):
    def __init__(self, model: Type[T]):
        self.model = model

    def get_by_id(self, db: Session, id: int) -> T | None:
        return db.query(self.model).filter(self.model.id == id).first()

    def get_all(self, db: Session) -> list[T]:
        return db.query(self.model).all()

    def create(self, db: Session, obj: T) -> T:
        db.add(obj)
        db.commit()
        db.refresh(obj)
        return obj

    def delete(self, db: Session, id: int) -> None:
        obj = self.get_by_id(db, id)
        if obj:
            db.delete(obj)
            db.commit()

    def update(self, db: Session, id: int, data: dict) -> T | None:
        obj = self.get_by_id(db, id)
        if obj:
            for key, value in data.items():
                setattr(obj, key, value)
            db.commit()
            db.refresh(obj)
        return obj