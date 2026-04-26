from app.models.adoption.adoption_process import AdoptionProcess
from app.models.adoption.adoption_steps.adoption_step import AdoptionStep
from app.models.adoption.adoption_steps.adoption_form import AdoptionForm
from app.models.adoption.adoption_steps.animal_pickup import AnimalPickup
from app.models.adoption.adoption_steps.contract import Contract
from app.models.adoption.adoption_steps.interview import Interview
from app.models.adoption.adoption_steps.shelter_visit import ShelterVisit
from app.schemas.adoption_schema.adoption_process_schema import AdoptionProcessResponse, AdoptionProcessDetailResponse
from app.schemas.adoption_schema.adoption_step_schema import AdoptionStepDetailResponse, AdoptionStepResponse


def step_to_detail_response(step: AdoptionStep) -> AdoptionStepDetailResponse:
    """transforms a single step into its detailed response schema"""
    base = dict(
        id=step.id,
        type=step.type,
        status=step.status,
        order=step.order,
        finish_date=step.finish_date,
        notes=step.notes,
        rejection_reason=step.rejection_reason,
    )
    if isinstance(step, AdoptionForm):
        base.update(accepted=step.accepted)
    elif isinstance(step, (Interview, ShelterVisit)):
        base.update(scheduled_at=step.scheduled_at)
    elif isinstance(step, Contract):
        base.update(
            signed_by_adoptant=step.signed_by_adoptant,
            signed_by_shelter=step.signed_by_shelter,
            contract_url=step.contract_url,
        )
    elif isinstance(step, AnimalPickup):
        base.update(
            scheduled_at=step.scheduled_at,
            actual_pickup_at=step.actual_pickup_at,
        )
    return AdoptionStepDetailResponse(**base)


def process_to_response(process: AdoptionProcess, steps: list[AdoptionStep]) -> AdoptionProcessResponse:
    return AdoptionProcessResponse(
        id=process.id,
        animal_id=process.animal_id,
        adoptant_id=process.adoptant_id,
        start_date=process.start_date,
        end_date=process.end_date,
        status=process.status,
        steps=[AdoptionStepResponse.model_validate(s) for s in steps],
    )


def process_to_detail_response(process: AdoptionProcess, steps: list[AdoptionStep]) -> AdoptionProcessDetailResponse:
    response_steps = []
    current_step_found = False
    rejection_reason = None

    for step in steps:
        step_resp = step_to_detail_response(step)

        if step.status == "PENDING" and not current_step_found:
            step_resp.is_current = True
            current_step_found = True

        if step.rejection_reason:
            rejection_reason = step.rejection_reason

        response_steps.append(step_resp)

    return AdoptionProcessDetailResponse(
        id=process.id,
        animal_id=process.animal_id,
        adoptant_id=process.adoptant_id,
        start_date=process.start_date,
        end_date=process.end_date,
        status=process.status,
        rejection_reason=rejection_reason,
        steps=response_steps,
    )