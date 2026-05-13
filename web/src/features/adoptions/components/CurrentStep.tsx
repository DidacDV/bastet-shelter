import type { AdoptionStep, ContractStep } from "../data/adoptionTypes";
import FormStepView from "./Formstep";
import InterviewStepView from "./InterviewStep";
import ShelterVisitStepView from "./ShelterVisitstep";
import ContractStepView from "./Contractstep";
import AnimalPickupStepView from "./AnimalPickupstep";

export default function CurrentStepView({
  step,
  processId,
  onContractSigned,
}: {
  step: AdoptionStep;
  processId: number;
  onContractSigned: (updated: ContractStep) => void;
}) {
  switch (step.type) {
    case "FORM":
      return <FormStepView step={step} />;
    case "INTERVIEW":
      return <InterviewStepView step={step} />;
    case "SHELTER_VISIT":
      return <ShelterVisitStepView step={step} />;
    case "CONTRACT":
      return (
        <ContractStepView
          step={step}
          processId={processId}
          onSigned={onContractSigned}
        />
      );
    case "ANIMAL_PICKUP":
      return <AnimalPickupStepView step={step} />;
    default:
      return null;
  }
}
