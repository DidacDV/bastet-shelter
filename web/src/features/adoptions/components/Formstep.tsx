import { Text } from "@mantine/core";
import type { FormStep } from "../data/adoptionTypes";
import { AppColors } from "../../../theme/constants";
import StepCardBase from "./StepCardBase";
import { useLocalization } from "../../../localization/localization";

export default function FormStepView({ step }: { step: FormStep }) {
  const { t } = useLocalization();

  return (
    <StepCardBase
      type={step.type}
      status={step.status}
      notes={step.notes}
      rejection_reason={step.rejection_reason}
      finish_date={step.finish_date}
    >
      <Text size="sm" style={{ color: AppColors.textSecondary }}>
        {t("adoption.formStepMessage")}
      </Text>
    </StepCardBase>
  );
}
