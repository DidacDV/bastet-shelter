export type AdoptionProcessStatus =
  | "PENDING"
  | "IN_PROGRESS"
  | "APPROVED"
  | "REJECTED"
  | "CANCELLED";

export type StepStatus = "PENDING" | "IN_PROGRESS" | "COMPLETED" | "REJECTED";

export type StepType =
  | "FORM"
  | "INTERVIEW"
  | "SHELTER_VISIT"
  | "CONTRACT"
  | "ANIMAL_PICKUP";

interface AdoptionStepBase {
  id: number;
  status: StepStatus;
  order: number;
  finish_date: string | null;
  notes: string | null;
  rejection_reason: string | null;
  is_current: boolean;
}

export interface FormStep extends AdoptionStepBase {
  type: "FORM";
  accepted: boolean;
}

export interface InterviewStep extends AdoptionStepBase {
  type: "INTERVIEW";
  scheduled_at: string | null;
}

export interface ShelterVisitStep extends AdoptionStepBase {
  type: "SHELTER_VISIT";
  scheduled_at: string | null;
}

export interface ContractStep extends AdoptionStepBase {
  type: "CONTRACT";
  signed_by_adoptant: boolean;
  signed_by_shelter: boolean;
  contract_url: string | null;
}

export interface AnimalPickupStep extends AdoptionStepBase {
  type: "ANIMAL_PICKUP";
  scheduled_at: string | null;
  actual_pickup_at: string | null;
}

export type AdoptionStep =
  | FormStep
  | InterviewStep
  | ShelterVisitStep
  | ContractStep
  | AnimalPickupStep;

export interface AdoptionProcessShort {
  id: number;
  animal_id: number;
  animal_name: string;
  animal_image_url: string | null;
  adoptant_id: number;
  adoptant_name: string;
  start_date: string;
  end_date: string | null;
  status: AdoptionProcessStatus;
  rejection_reason: string | null;
}

export interface AdoptionProcessDetail extends AdoptionProcessShort {
  steps: AdoptionStep[];
}

export interface AdoptionFormSubmit {
  housing_type?: string;
  has_garden?: boolean;
  has_other_pets?: boolean;
  other_pets_description?: string;
  has_children?: boolean;
  children_ages?: string;
  previous_pet_experience?: boolean;
  hours_alone_per_day?: number;
  reason_for_adoption?: string;
}
