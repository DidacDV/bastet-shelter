import { Group, Text } from "@mantine/core";
import { IconCalendar, IconMail } from "@tabler/icons-react";
import type { InterviewStep } from "../data/adoptionTypes";
import { AppColors } from "../../../theme/constants";
import StepCardBase from "./StepCardBase";
import { useLocalization } from "../../../localization/localization";

export default function InterviewStepView({ step }: { step: InterviewStep }) {
  const { locale, t } = useLocalization();

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
            {t("adoption.scheduledFor")}{" "}
            <Text span fw={600} style={{ color: AppColors.textDark }}>
              {new Date(step.scheduled_at).toLocaleDateString(locale, {
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
            {t("adoption.interviewFallback")}
          </Text>
        </Group>
      )}
    </StepCardBase>
  );
}
