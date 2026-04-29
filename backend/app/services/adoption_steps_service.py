from datetime import date, datetime
from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.models.adoption.adoption_steps.adoption_step import AdoptionStep, StepStatusEnum, StepTypeEnum
from app.models.adoption.adoption_steps.adoption_form import AdoptionForm
from app.models.adoption.adoption_steps.animal_pickup import AnimalPickup
from app.models.adoption.adoption_steps.contract import Contract
from app.models.adoption.adoption_steps.interview import Interview
from app.models.adoption.adoption_steps.shelter_visit import ShelterVisit
from app.repositories.adoption.adoption_process_repo import AdoptionProcessRepository
from app.repositories.adoption.adoption_step_repo import AdoptionStepRepository
from app.schemas.adoption_schema.adoption_mappers import step_to_detail_response
from app.schemas.adoption_schema.adoption_schema import ScheduledDateUpdate, NotesUpdate
from app.schemas.adoption_schema.adoption_step_schema import AdvanceStepRequest, InterviewResponse, \
    ShelterVisitResponse, AnimalPickupResponse, AdoptionStepBaseResponse, ContractResponse


class AdoptionStepsService:
    def __init__(self, db: Session):
        self.db = db
        self.step_repo = AdoptionStepRepository(db)
        self.process_repo = AdoptionProcessRepository(db)

    def _get_current_step_or_raise(self, process_id: int) -> AdoptionStep:
        step = self.step_repo.get_current_step(self.db, process_id)
        if not step:
            raise NotFoundError("No pending steps found for this adoption process")
        return step

    def _check_has_scheduled_date_passed(self, scheduled_at: datetime | None, step_name: str) -> None:
        if not scheduled_at:
            raise BusinessLogicError(f"{step_name} has no scheduled date set yet")
        if datetime.now() < scheduled_at:
            raise BusinessLogicError(f"{step_name} scheduled date has not passed yet")

    def _advance_form(self, step: AdoptionForm, request: AdvanceStepRequest) -> None:
        step.accepted = True
        step.status = StepStatusEnum.COMPLETED
        step.finish_date = date.today()
        if request.notes is not None:
            step.notes = request.notes

    def _advance_interview(self, step: Interview, request: AdvanceStepRequest) -> None:
        self._check_has_scheduled_date_passed(step.scheduled_at, "Interview")
        step.status = StepStatusEnum.COMPLETED
        step.finish_date = date.today()
        step.notes = request.notes
        if request.notes is not None:
            step.notes = request.notes

    def _advance_shelter_visit(self, step: ShelterVisit, request: AdvanceStepRequest) -> None:
        self._check_has_scheduled_date_passed(step.scheduled_at, "Shelter visit")
        step.status = StepStatusEnum.COMPLETED
        step.finish_date = date.today()
        step.notes = request.notes
        if request.notes is not None:
            step.notes = request.notes

    def _advance_contract(self, step: Contract, request: AdvanceStepRequest) -> None:
        if not step.signed_by_adoptant or not step.signed_by_shelter:
            raise BusinessLogicError("Contract has to be signed by both parties before it can be completed.")

        step.status = StepStatusEnum.COMPLETED
        step.finish_date = date.today()
        step.notes = request.notes
        if request.notes is not None:
            step.notes = request.notes

    def _advance_animal_pickup(self, step: AnimalPickup, request: AdvanceStepRequest) -> None:
        self._check_has_scheduled_date_passed(step.scheduled_at, "Animal pickup")
        step.actual_pickup_at = datetime.now()
        step.status = StepStatusEnum.COMPLETED
        step.finish_date = date.today()
        step.notes = request.notes
        if request.notes is not None:
            step.notes = request.notes

    def advance_current_step(self, process_id: int, request: AdvanceStepRequest) -> None:
        """completes the current pending step (and advances to the next one)"""
        current_step = self._get_current_step_or_raise(process_id)

        advance_handlers = {
            StepTypeEnum.FORM: self._advance_form,
            StepTypeEnum.INTERVIEW: self._advance_interview,
            StepTypeEnum.SHELTER_VISIT: self._advance_shelter_visit,
            StepTypeEnum.CONTRACT: self._advance_contract,
            StepTypeEnum.ANIMAL_PICKUP: self._advance_animal_pickup,
        }

        handler = advance_handlers.get(current_step.type)
        if not handler:
            raise BusinessLogicError(f"Unknown step type: {current_step.type}")

        handler(current_step, request) # type: ignore (in runtime, the correct value is obtained from the dictionary)
        self.db.commit()
        self.db.refresh(current_step)

    def skip_step(self, process_id: int) -> None:
        current_step = self._get_current_step_or_raise(process_id)

        if current_step.type == StepTypeEnum.FORM:
            raise BusinessLogicError("The form step cannot be skipped")
        if current_step.type == StepTypeEnum.ANIMAL_PICKUP:
            raise BusinessLogicError("The animal pickup step cannot be skipped")

        current_step.status = StepStatusEnum.SKIPPED
        current_step.finish_date = date.today()
        self.db.commit()

    def has_pending_steps(self, process_id: int) -> bool:
        return self.step_repo.get_current_step(self.db, process_id) is not None

    def get_form_details(self, process_id: int) -> AdoptionForm:
        """ gets the form details for the given process"""
        steps = self.step_repo.get_steps_for_process(self.db, process_id)
        form = next((s for s in steps if isinstance(s, AdoptionForm)), None)
        if not form:
            raise NotFoundError("Form step not found for this process")
        return form

    def _set_scheduled_date(self, process_id: int, step_type: StepTypeEnum, scheduled_at: datetime) -> AdoptionStepBaseResponse:
        steps = self.step_repo.get_steps_for_process(self.db, process_id)
        step = next((s for s in steps if s.type == step_type), None)

        current_step = self._get_current_step_or_raise(process_id)

        if current_step.type != step_type:
            raise BusinessLogicError(
                f"You cannot schedule the {step_type.value} until the {current_step.type.value} is completed.")

        if not step:
            raise NotFoundError(f"{step_type.value} step not found for this process")
        if step.status != StepStatusEnum.PENDING:
            raise BusinessLogicError(f"{step_type.value} step is already {step.status.value.lower()}")

        step.scheduled_at = scheduled_at
        self.db.commit()
        self.db.refresh(step)
        return step_to_detail_response(step)

    def set_interview_scheduled_date(self, process_id: int, data: ScheduledDateUpdate) -> InterviewResponse:
        return self._set_scheduled_date(process_id, StepTypeEnum.INTERVIEW, data.scheduled_at)  # type: ignore

    def set_shelter_visit_scheduled_date(self, process_id: int, data: ScheduledDateUpdate) -> ShelterVisitResponse:
        return self._set_scheduled_date(process_id, StepTypeEnum.SHELTER_VISIT, data.scheduled_at) # type: ignore

    def set_animal_pickup_scheduled_date(self, process_id: int, data: ScheduledDateUpdate) -> AnimalPickupResponse:
        return self._set_scheduled_date(process_id, StepTypeEnum.ANIMAL_PICKUP, data.scheduled_at) # type: ignore

    def set_animal_pickup_actual_date(self, process_id: int, step_id: int, data: ScheduledDateUpdate) -> AnimalPickupResponse:
        """Sets the actual date the animal was picked up incase it doesnt match the scheduled date"""
        step = self.step_repo.get_by_id(self.db, step_id)
        if not step:
            raise NotFoundError("Animal pickup step not found")

        if not isinstance(step, AnimalPickup):
            raise BusinessLogicError("This step is not an animal pickup step")
        if step.adoption_process_id != process_id:
            raise BusinessLogicError("Step does not belong to this process")
        if step.scheduled_at is None:
            raise BusinessLogicError("Animal pickup step has no scheduled date set")

        step.actual_pickup_at = data.scheduled_at

        self.db.commit()
        self.db.refresh(step)
        return step_to_detail_response(step)  # type: ignore

    def add_notes(self, process_id: int, step_id: int, notes: NotesUpdate) -> AdoptionStepBaseResponse:
        step = self.step_repo.get_by_id(self.db, step_id)
        if not step:
            raise NotFoundError("Step not found")
        if step.adoption_process_id != process_id:
            raise BusinessLogicError("Step does not belong to this process")
        step.notes = notes.notes
        self.db.commit()
        self.db.refresh(step)
        return step_to_detail_response(step)

    def _get_contract_step_or_raise(self, process_id: int) -> Contract:
        steps = self.step_repo.get_steps_for_process(self.db, process_id)
        contract = next((s for s in steps if isinstance(s, Contract)), None)
        if not contract:
            raise NotFoundError("Contract step not found for this process")
        return contract

    def update_adoptant_signature(self, process_id: int, adoptant_id: int) -> ContractResponse:
        process = self.process_repo.get_by_id(self.db, process_id)
        if not process:
            raise NotFoundError("Adoption process not found")
        if process.adoptant_id != adoptant_id:
            raise BusinessLogicError("You are not the adoptant of this process")
        contract = self._get_contract_step_or_raise(process_id)
        contract.signed_by_adoptant = True
        self.db.commit()
        self.db.refresh(contract)
        return step_to_detail_response(contract)  # type: ignore

    def update_shelter_signature(self, process_id: int) -> ContractResponse:
        contract = self._get_contract_step_or_raise(process_id)
        contract.signed_by_shelter = not contract.signed_by_shelter
        self.db.commit()
        self.db.refresh(contract)
        return step_to_detail_response(contract)  # type: ignore