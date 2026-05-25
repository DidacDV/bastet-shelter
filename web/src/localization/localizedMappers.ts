import type {
  AdoptionProcessStatus,
  StepStatus,
  StepType,
} from "../features/adoptions/data/adoptionTypes";
import type { TranslationKey } from "./localization";

export type AnimalType = "CAT" | "DOG" | "OTHER";

export function animalTypeKey(type: AnimalType): TranslationKey {
  return `animals.type.${type.toLowerCase()}` as TranslationKey;
}

export function adoptionStatusKey(status: AdoptionProcessStatus): TranslationKey {
  return `adoption.status.${status.toLowerCase()}` as TranslationKey;
}

export function stepStatusKey(status: StepStatus): TranslationKey {
  return `adoption.stepStatus.${status.toLowerCase()}` as TranslationKey;
}

export function stepTypeKey(type: StepType, short = false): TranslationKey {
  if (short && type === "ANIMAL_PICKUP") {
    return "adoption.step.pickup";
  }

  const keys: Record<StepType, TranslationKey> = {
    FORM: "adoption.step.form",
    INTERVIEW: "adoption.step.interview",
    SHELTER_VISIT: "adoption.step.shelterVisit",
    CONTRACT: "adoption.step.contract",
    ANIMAL_PICKUP: "adoption.step.animalPickup",
  };

  return keys[type];
}
