from datetime import datetime, date
from app.models.refuge import Refuge
from app.models.shelter_member import Volunteer, RoleEnum
from app.models.shift.shift import Shift
from app.models.shift.shift_participant import ShiftParticipant
from app.repositories.shift_participant_repo import ShiftParticipantRepository
from tests.repositories.utils import _create_user, _create_shelter

def test_get_by_shift(db):
    repo = ShiftParticipantRepository(db)

    shelter = _create_shelter(db)
    refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
    db.add(refuge)
    db.commit()
    db.refresh(refuge)

    shift = Shift(
        start_time=datetime(2023, 10, 10, 8, 0),
        end_time=datetime(2023, 10, 10, 12, 0),
        day=date(2023, 10, 10),
        shelter_id=shelter.id,
        refuge_id=refuge.id
    )
    db.add(shift)
    db.commit()
    db.refresh(shift)

    user = _create_user(db)
    volunteer = Volunteer(user_id=user.id, shelter_id=shelter.id, role=RoleEnum.VOLUNTEER)
    db.add(volunteer)
    db.commit()
    db.refresh(volunteer)

    participant = ShiftParticipant(shift_id=shift.id, member_id=volunteer.id)
    db.add(participant)
    db.commit()

    result = repo.get_by_shift(db, shift.id)
    assert len(result) == 1
    assert result[0].shift_id == shift.id


def test_get_by_volunteer(db):
    repo = ShiftParticipantRepository(db)

    shelter = _create_shelter(db)
    refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
    db.add(refuge)
    db.commit()
    db.refresh(refuge)

    shift = Shift(
        start_time=datetime(2023, 10, 10, 8, 0),
        end_time=datetime(2023, 10, 10, 12, 0),
        day=date(2023, 10, 10),
        shelter_id=shelter.id,
        refuge_id=refuge.id
    )
    db.add(shift)
    db.commit()
    db.refresh(shift)

    user = _create_user(db)
    volunteer = Volunteer(user_id=user.id, shelter_id=shelter.id, role=RoleEnum.VOLUNTEER)
    db.add(volunteer)
    db.commit()
    db.refresh(volunteer)

    participant = ShiftParticipant(shift_id=shift.id, member_id=volunteer.id)
    db.add(participant)
    db.commit()

    result = repo.get_by_volunteer(db, volunteer.id)
    assert len(result) == 1
    assert result[0].member_id == volunteer.id


def test_get_by_shift_and_member(db):
    repo = ShiftParticipantRepository(db)

    shelter = _create_shelter(db)
    refuge = Refuge(name="Test Refuge", province_id="08", shelter_id=shelter.id)
    db.add(refuge)
    db.commit()
    db.refresh(refuge)

    shift = Shift(
        start_time=datetime(2023, 10, 10, 8, 0),
        end_time=datetime(2023, 10, 10, 12, 0),
        day=date(2023, 10, 10),
        shelter_id=shelter.id,
        refuge_id=refuge.id
    )
    db.add(shift)
    db.commit()
    db.refresh(shift)

    user = _create_user(db)
    volunteer = Volunteer(user_id=user.id, shelter_id=shelter.id, role=RoleEnum.VOLUNTEER)
    db.add(volunteer)
    db.commit()
    db.refresh(volunteer)

    participant = ShiftParticipant(shift_id=shift.id, member_id=volunteer.id)
    db.add(participant)
    db.commit()

    result = repo.get_by_shift_and_member(db, shift.id, volunteer.id)
    assert result is not None
    assert result.shift_id == shift.id
    assert result.member_id == volunteer.id

    result_none = repo.get_by_shift_and_member(db, shift.id, 9999)
    assert result_none is None