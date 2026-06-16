import io
from datetime import date
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.email.email_sender import send_email
from app.core.email.templates import (
    adoption_completed_email,
    adoption_rejected_email,
    adoption_request_received_email,
    adoption_request_shelter_email,
)
from app.core.exceptions import NotFoundError, BusinessLogicError, AuthorizationError
from app.models.adoption.adoption_process import AdoptionProcess, AdoptionProcessStatusEnum
from app.models.adoption.adoption_steps.adoption_step import AdoptionStep, StepStatusEnum, StepTypeEnum, STEP_ORDER
from app.models.adoption.adoption_steps.adoption_form import AdoptionForm
from app.models.adoption.adoption_steps.animal_pickup import AnimalPickup
from app.models.adoption.adoption_steps.contract import Contract
from app.models.adoption.adoption_steps.interview import Interview
from app.models.adoption.adoption_steps.shelter_visit import ShelterVisit
from app.repositories.adoption.adoptant_repo import AdoptantRepository
from app.repositories.adoption.adoption_process_repo import AdoptionProcessRepository
from app.repositories.adoption.adoption_step_repo import AdoptionStepRepository
from app.repositories.animal_repo import AnimalRepository
from app.schemas.adoption_schema.adoptant_schema import AdoptantResponse
from app.schemas.adoption_schema.adoption_form_schema import AdoptionFormSubmit

from app.schemas.adoption_schema.adoption_mappers import process_to_response, process_to_detail_response, process_to_adoptant_response
from app.schemas.adoption_schema.adoption_process_schema import AdoptionProcessResponse, AdoptionProcessDetailResponse, AdoptionProcessAdoptantResponse
from app.services.pdf import pdf_service

import cloudinary.uploader as cloudinary_uploader
from fastapi import BackgroundTasks


UNTOGGLE_ADOPTION_REASON = "This adoption process has been rejected because the animal is no longer in adoption."

class AdoptionProcessService:
    def __init__(self, db: Session):
        self.db = db
        self.adoptant_repo = AdoptantRepository(db)
        self.process_repo = AdoptionProcessRepository(db)
        self.step_repo = AdoptionStepRepository(db)
        self.animal_repo = AnimalRepository(db)

    def _get_process_or_raise(self, process_id: int) -> AdoptionProcess:
        process = self.process_repo.get_by_id(self.db, process_id)
        if not process:
            raise NotFoundError("Adoption process not found")
        return process

    def check_is_process_active(self, process_id: int) -> None:
        process = self._get_process_or_raise(process_id)
        if process.status != AdoptionProcessStatusEnum.ACTIVE:
            raise BusinessLogicError("Adoption process is not active")

    def _initialize_steps_for_new_process(self, process_id: int) -> list[AdoptionStep]:
        step_classes = {
            StepTypeEnum.FORM: AdoptionForm,
            StepTypeEnum.INTERVIEW: Interview,
            StepTypeEnum.SHELTER_VISIT: ShelterVisit,
            StepTypeEnum.CONTRACT: Contract,
            StepTypeEnum.ANIMAL_PICKUP: AnimalPickup,
        }
        return [
            step_classes[step_type](
                adoption_process_id=process_id,
                type=step_type,
                status=StepStatusEnum.PENDING,
                order=order,
            )
            for order, step_type in enumerate(STEP_ORDER)
        ]

    def _check_belongs_to_shelter(self, process: AdoptionProcess, shelter_id: int) -> None:
        from app.models.refuge import Refuge
        animal = self.animal_repo.get_by_id(self.db, process.animal_id)
        refuge = self.db.query(Refuge).filter(Refuge.id == animal.refuge_id).first()
        if not refuge or refuge.shelter_id != shelter_id:
            raise AuthorizationError("Not authorized to view this adoption process")

    def start_adoption(
        self,
        animal_id: int,
        adoptant_email: str,
        adoptant_name: str,
        form_data: AdoptionFormSubmit,
        background_tasks: BackgroundTasks,
    ) -> AdoptionProcessResponse:
        """an adoption process starts with an adoptant sending the form for X animal adoption"""
        animal = self.animal_repo.get_by_id(self.db, animal_id)
        if not animal:
            raise NotFoundError("Animal not found")
        if not animal.in_adoption:
            raise BusinessLogicError("Animal is not available for adoption")

        existing = self.process_repo.get_active_process_for_animal(self.db, animal_id)
        if existing:
            raise BusinessLogicError("An active adoption process already exists for this animal")

        adoptant = self.adoptant_repo.get_or_create(self.db, adoptant_email, adoptant_name)

        process = AdoptionProcess(
            animal_id=animal_id,
            adoptant_id=adoptant.id,
            start_date=date.today(),
            status=AdoptionProcessStatusEnum.ACTIVE,
        )
        self.db.add(process)
        self.db.flush()

        steps = self._initialize_steps_for_new_process(process.id)

        form_step: AdoptionForm = steps[0]
        for field, value in form_data.model_dump(exclude_none=True).items():
            setattr(form_step, field, value)

        for step in steps:
            self.db.add(step)

        self.db.commit()
        self.db.refresh(process)

        html_body = adoption_request_received_email(
            adoptant_name=adoptant_name,
            animal_name=animal.name,
            frontend_url=settings.frontend_base_url,
        )
        send_email(
            subject=f"We've received your adoption application for {animal.name}",
            recipients=[adoptant_email],
            body=html_body,
            background_tasks=background_tasks,
        )

        shelter = animal.refuge.shelter if animal.refuge else None
        if shelter and shelter.email:
            shelter_html_body = adoption_request_shelter_email(
                shelter_name=shelter.name,
                adoptant_name=adoptant_name,
                adoptant_email=adoptant_email,
                animal_name=animal.name,
                frontend_url=settings.frontend_base_url,
            )
            send_email(
                subject=f"New adoption application for {animal.name}",
                recipients=[shelter.email],
                body=shelter_html_body,
                background_tasks=background_tasks,
            )

        return process_to_response(process, steps)

    def _cancel_process(self, process: AdoptionProcess, background_tasks: BackgroundTasks, reason: str = UNTOGGLE_ADOPTION_REASON) -> None:
        """rejects all pending steps, marks process rejected, and notifies adoptant."""
        if reason:
            current_step = self.step_repo.get_current_step(self.db, process.id)
            if current_step:
                current_step.rejection_reason = reason

        self.step_repo.mark_all_rejected(self.db, process.id)
        self.process_repo.mark_rejected(self.db, process)
        html_body = adoption_rejected_email(
            adoptant_name=process.adoptant.name,
            animal_name=process.animal.name,
            reason=reason
        )

        send_email(
            subject=f"Update regarding your adoption application for {process.animal.name}",
            recipients=[str(process.adoptant.email)],
            body=html_body,
            background_tasks=background_tasks
        )

    def cancel_adoption(self, process_id: int, adoptant_id: int, background_tasks: BackgroundTasks) -> None:
        """done by ADOPTANT"""
        process = self._get_process_or_raise(process_id)
        if process.adoptant_id != adoptant_id:
            raise AuthorizationError("Not authorized to cancel this adoption process")
        self.check_is_process_active(process_id)

        self._cancel_process(process, background_tasks)

    def reject_adoption(self, process_id: int, shelter_id: int, reason: str, background_tasks: BackgroundTasks) -> None:
        """rejected by a shelter MANAGER"""
        process = self._get_process_or_raise(process_id)

        self._check_belongs_to_shelter(process, shelter_id)
        self.check_is_process_active(process_id)

        self._cancel_process(process, reason=reason, background_tasks=background_tasks)

    def cancel_all_active_for_animal(self, animal_id: int, background_tasks: BackgroundTasks) -> None:
        """vancel all active adoption processes for an animal"""
        active_processes = self.process_repo.get_all_active_processes_for_animal(self.db, animal_id)
        for process in active_processes:
            self._cancel_process(process, background_tasks=background_tasks)

    def mark_process_completed(self, process_id: int, background_tasks: BackgroundTasks) -> None:
        """marks the entire adoption process as completed (its steps too)"""
        process = self._get_process_or_raise(process_id)
        self.process_repo.mark_completed(self.db, process)
        process.animal.in_adoption = False
        html_body = adoption_completed_email(
            adoptant_name=process.adoptant.name,
            animal_name=process.animal.name
        )

        send_email(
            subject=f"Great news! Your adoption process for {process.animal.name} is complete 🐾",
            recipients=[str(process.adoptant.email)],
            body=html_body,
            background_tasks=background_tasks
        )

    def get_adoption_process_details(self, process_id: int) -> AdoptionProcessDetailResponse:
        """full details"""
        process = self._get_process_or_raise(process_id)
        steps = self.step_repo.get_steps_for_process(self.db, process.id)
        return process_to_detail_response(process, steps)

    def get_adoption_process_steps_manager(self, process_id: int, shelter_id: int) -> AdoptionProcessDetailResponse:
        """full details for shelter manager"""
        process = self._get_process_or_raise(process_id)
        self._check_belongs_to_shelter(process, shelter_id)
        steps = self.step_repo.get_steps_for_process(self.db, process.id)
        return process_to_detail_response(process, steps)

    def get_adoption_process_steps_adoptant(self, process_id: int, adoptant_id: int) -> AdoptionProcessAdoptantResponse:
        """adoptant views their own adoption process: current step with full detail, others as summary"""
        process = self._get_process_or_raise(process_id)
        if process.adoptant_id != adoptant_id:
            raise AuthorizationError("Not authorized to view this adoption process")
        steps = self.step_repo.get_steps_for_process(self.db, process.id)
        return process_to_adoptant_response(process, steps)

    def get_all_processes_for_shelter(self, shelter_id: int) -> list[AdoptionProcessResponse]:
        processes = self.process_repo.get_processes_for_shelter(self.db, shelter_id)
        return [
            process_to_response(p, self.step_repo.get_steps_for_process(self.db, p.id))
            for p in processes
        ]

    def get_all_processes_for_adoptant(self, adoptant_id: int) -> list[AdoptionProcessResponse]:
        processes = self.process_repo.get_processes_for_adoptant(self.db, adoptant_id)
        return [
            process_to_response(p, self.step_repo.get_steps_for_process(self.db, p.id))
            for p in processes
        ]

    def get_adoptant(self, adoptant_id: int, shelter_id: int) -> AdoptantResponse:
        adoptant = self.adoptant_repo.get_by_id(self.db, adoptant_id)
        if not adoptant:
            raise NotFoundError("Adoptant not found")

        if not self.adoptant_repo.has_process_in_shelter(self.db, adoptant_id, shelter_id):
            raise AuthorizationError("Adoptant does not have an active adoption process in this shelter")

        return AdoptantResponse.model_validate(adoptant)

    def generate_pdf(self, process_id: int, shelter_id: int) -> str:
        process = self.process_repo.get_by_id(self.db, process_id)
        if not process:
            raise NotFoundError("Adoption process not found")
        animal = process.animal
        adoptant = process.adoptant
        if not animal or not adoptant:
            raise NotFoundError("Animal or adoptant not found")

        steps = self.step_repo.get_steps_for_process(self.db, process_id)
        contract_step: Contract | None = next((s for s in steps if isinstance(s, Contract)), None)
        if not contract_step:
            raise NotFoundError("Contract step not found for this process")
        if contract_step.status not in (StepStatusEnum.PENDING,):
            raise BusinessLogicError("Contract step is not in a state that allows PDF generation")

        file_name = f"contract_{process_id}_{animal.name}_{adoptant.name}".replace(" ", "_")

        pdfbytes = pdf_service.generate_contract_pdf(animal=animal, adoptant=adoptant)
        result = cloudinary_uploader.upload(
            io.BytesIO(pdfbytes),
            folder=f"shelters/{shelter_id}/contracts/",
            public_id=file_name,
            resource_type="raw",
            format="pdf"
        )

        contract_step.contract_url = result["secure_url"]
        contract_step.cloudinary_public_id = result["public_id"]
        contract_step.generation_date = date.today()
        self.db.commit()

        return contract_step.contract_url #type: ignore