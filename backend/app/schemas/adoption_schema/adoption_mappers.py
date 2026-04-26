from app.models.adoption.adoption_process import AdoptionProcess
from app.models.adoption.adoption_steps.adoption_step import AdoptionStep, StepTypeEnum
from app.schemas.adoption_schema.adoption_process_schema import AdoptionProcessResponse, AdoptionProcessDetailResponse
from app.schemas.adoption_schema.adoption_step_schema import AdoptionStepResponse, \
    AdoptionStepBaseResponse, AnimalPickupResponse, ContractResponse, ShelterVisitResponse, InterviewResponse, \
    AdoptionFormResponse

STEP_RESPONSE_CLASS = {
    StepTypeEnum.FORM: AdoptionFormResponse,
    StepTypeEnum.INTERVIEW: InterviewResponse,
    StepTypeEnum.SHELTER_VISIT: ShelterVisitResponse,
    StepTypeEnum.CONTRACT: ContractResponse,
    StepTypeEnum.ANIMAL_PICKUP: AnimalPickupResponse,
}

def step_to_detail_response(step: AdoptionStep) -> AdoptionStepBaseResponse:
    response_class = STEP_RESPONSE_CLASS[step.type]
    return response_class.model_validate(step)


def process_to_response(process: AdoptionProcess, steps: list[AdoptionStep]) -> AdoptionProcessResponse:
    primary_image = min(process.animal.images, key=lambda i: i.order, default=None)

    return AdoptionProcessResponse(
        id=process.id,
        animal_id=process.animal_id,
        adoptant_id=process.adoptant_id,
        start_date=process.start_date,
        end_date=process.end_date,
        status=process.status,
        steps=[AdoptionStepResponse.model_validate(s) for s in steps],
        animal_name=process.animal.name,
        animal_image_url=primary_image.url if primary_image else None,
        adoptant_name=process.adoptant.name,
    )


def process_to_detail_response(process: AdoptionProcess, steps: list[AdoptionStep]) -> AdoptionProcessDetailResponse:
    response_steps = []
    current_step_found = False
    for step in steps:
        step_resp = step_to_detail_response(step)

        if step.status == "PENDING" and not current_step_found:
            step_resp.is_current = True
            current_step_found = True

        response_steps.append(step_resp)

    return AdoptionProcessDetailResponse(
        id=process.id,
        animal_id=process.animal_id,
        adoptant_id=process.adoptant_id,
        start_date=process.start_date,
        end_date=process.end_date,
        status=process.status,
        steps=response_steps,
    )