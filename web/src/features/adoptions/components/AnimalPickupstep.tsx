import { Stack, Group, Text } from "@mantine/core";
import { IconCalendar, IconCircleCheck } from "@tabler/icons-react";
import type { AnimalPickupStep } from "../data/adoptionTypes";
import { AppColors } from "../../../theme/constants";
import StepCardBase from "./StepCardBase";
import { useLocalization } from "../../../localization/localization";

function DateRow({
  icon,
  label,
  value,
  fallback,
}: {
  icon: React.ReactNode;
  label: string;
  value: string | null;
  fallback: string;
}) {
  const { t } = useLocalization();

  return (
    <Group gap={8} align="flex-start">
      <div style={{ marginTop: 2, color: AppColors.textHint }}>{icon}</div>
      <Stack gap={0}>
        <Text size="xs" style={{ color: AppColors.textHint }}>
          {label}
        </Text>
        {value ? (
          <Text size="sm" fw={600} style={{ color: AppColors.textDark }}>
            {new Date(value).toLocaleDateString(undefined, {
              weekday: "long",
              year: "numeric",
              month: "long",
              day: "numeric",
            })}
          </Text>
        ) : (
          <Text size="sm" style={{ color: AppColors.textSecondary }}>
            {fallback}
          </Text>
        )}
      </Stack>
    </Group>
  );
}

export default function AnimalPickupStepView({
  step,
}: {
  step: AnimalPickupStep;
}) {
  return (
    <StepCardBase
      type={step.type}
      status={step.status}
      notes={step.notes}
      rejection_reason={step.rejection_reason}
      finish_date={step.finish_date}
    >
      <Stack gap="md">
        <DateRow
          icon={<IconCalendar size={16} />}
          label={t("adoption.scheduledPickup")}
          value={step.scheduled_at}
          fallback={t("adoption.pickupFallback")}
        />
        <DateRow
          icon={<IconCircleCheck size={16} />}
          label={t("adoption.actualPickup")}
          value={step.actual_pickup_at}
          fallback={t("adoption.notPickedUp")}
        />
      </Stack>
    </StepCardBase>
  );
}
