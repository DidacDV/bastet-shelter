from app.repositories.task_repo import TaskRepository
from app.models.task.task import Task
from tests.repositories.utils import _create_shelter

class TestTaskRepository:
    repo = TaskRepository(None)

    def test_get_by_shelter(self, db):
        shelter = _create_shelter(db)
        task = Task(title="Test Task", description="Desc", num_people=1, shelter_id=shelter.id)
        db.add(task)
        db.commit()

        result = self.repo.get_by_shelter(db, shelter.id)
        assert len(result) == 1
        assert result[0].shelter_id == shelter.id

    def test_create(self, db):
        shelter = _create_shelter(db)
        task = Task(title="Created Task", description="Desc", num_people=1, shelter_id=shelter.id)
        result = self.repo.create(db, task)
        assert result.id is not None
        assert result.title == "Created Task"

    def test_get_all(self, db):
        shelter = _create_shelter(db)
        task = Task(title="Test Task", description="Desc", num_people=1, shelter_id=shelter.id)
        db.add(task)
        db.commit()

        result = self.repo.get_all(db)
        assert len(result) >= 1
