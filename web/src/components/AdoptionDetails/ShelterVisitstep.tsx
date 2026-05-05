import { Group, Text } from "@mantine/core";
import { IconCalendar, IconMail } from "@tabler/icons-react";
import type { ShelterVisitStep } from "../../features/adoptions/adoptionTypes";
import { AppColors } from "../../theme/constants";
import StepCardBase from "./StepCardBase";

export default function ShelterVisitStepView({
  step,
}: {
  step: ShelterVisitStep;
}) {
  return (
    <StepCardBase
      type={step.type}
      status={step.status}
      notes={step.notes}
      rejection_reason={step.rejection_reason}
      finish_date={step.finish_date}
    >
      {step.scheduled_at ? (
        <Group gap={8} align="center">
          <IconCalendar size={16} color={AppColors.textHint} />
          <Text size="sm" style={{ color: AppColors.textSecondary }}>
            Scheduled for{" "}
            <Text span fw={600} style={{ color: AppColors.textDark }}>
              {new Date(step.scheduled_at).toLocaleDateString(undefined, {
                weekday: "long",
                year: "numeric",
                month: "long",
                day: "numeric",
              })}
            </Text>
          </Text>
        </Group>
      ) : (
        <Group gap={8} align="flex-start">
          <IconMail
            size={16}
            color={AppColors.textHint}
            style={{ marginTop: 2 }}
          />
          <Text size="sm" style={{ color: AppColors.textSecondary }}>
            The shelter will reach out to arrange your visit via the email
            address on your account.
          </Text>
        </Group>
      )}
    </StepCardBase>
  );
}
