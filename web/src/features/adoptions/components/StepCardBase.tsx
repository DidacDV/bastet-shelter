import { Card, Group, Text, Badge, Stack, Divider, Alert } from "@mantine/core";
import { IconAlertCircle, IconNotes } from "@tabler/icons-react";
import type { StepStatus, StepType } from "../data/adoptionTypes";
import { AppColors } from "../../../theme/constants";
import { useLocalization } from "../../../localization/localization";
import {
  stepStatusKey,
  stepTypeKey,
} from "../../../localization/localizedMappers";

const STATUS_COLORS: Record<StepStatus, string> = {
  PENDING: "yellow",
  IN_PROGRESS: "blue",
  COMPLETED: "green",
  REJECTED: "red",
};

interface StepCardBaseProps {
  type: StepType;
  status: StepStatus;
  notes: string | null;
  rejection_reason: string | null;
  finish_date: string | null;
  children?: React.ReactNode;
}

export default function StepCardBase({
  type,
  status,
  notes,
  rejection_reason,
  finish_date,
  children,
}: StepCardBaseProps) {
  const { locale, t } = useLocalization();

  return (
    <Card
      radius="md"
      padding="lg"
      style={{ border: `1px solid ${AppColors.divider}` }}
    >
      <Stack gap="md">
        <Group justify="space-between" align="center">
          <Text fw={700} size="lg" style={{ color: AppColors.textDark }}>
            {t(stepTypeKey(type))}
          </Text>
          <Badge variant="light" color={STATUS_COLORS[status]} size="md">
            {t(stepStatusKey(status))}
          </Badge>
        </Group>

        {finish_date && (
          <Text size="sm" style={{ color: AppColors.textSecondary }}>
            {t("adoption.completedOn", {
              date: new Date(finish_date).toLocaleDateString(locale, {
              year: "numeric",
              month: "long",
              day: "numeric",
              }),
            })}
          </Text>
        )}

        {children && (
          <>
            <Divider />
            {children}
          </>
        )}

        {rejection_reason && (
          <Alert
            icon={<IconAlertCircle size={16} />}
            color="red"
            variant="light"
            title={t("adoption.rejectionReason")}
          >
            {rejection_reason}
          </Alert>
        )}

        {notes && (
          <Group gap={6} align="flex-start">
            <IconNotes
              size={15}
              color={AppColors.textHint}
              style={{ marginTop: 2 }}
            />
            <Text size="sm" style={{ color: AppColors.textSecondary }}>
              {notes}
            </Text>
          </Group>
        )}
      </Stack>
    </Card>
  );
}
