import { Text } from "@mantine/core";
import type { FormStep } from "../../features/adoptions/adoptionTypes";
import { AppColors } from "../../theme/constants";
import StepCardBase from "./StepCardBase";

export default function FormStepView({ step }: { step: FormStep }) {
  return (
    <StepCardBase
      type={step.type}
      status={step.status}
      notes={step.notes}
      rejection_reason={step.rejection_reason}
      finish_date={step.finish_date}
    >
      <Text size="sm" style={{ color: AppColors.textSecondary }}>
        Your adoption form has been submitted and is being reviewed by the
        shelter. You will be notified once a decision has been made.
      </Text>
    </StepCardBase>
  );
}
