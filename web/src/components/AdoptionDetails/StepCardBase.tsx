import { Card, Group, Text, Badge, Stack, Divider, Alert } from "@mantine/core";
import { IconAlertCircle, IconNotes } from "@tabler/icons-react";
import type {
  StepStatus,
  StepType,
} from "../../features/adoptions/adoptionTypes";
import { AppColors } from "../../theme/constants";

const STEP_LABELS: Record<StepType, string> = {
  FORM: "Adoption Form",
  INTERVIEW: "Interview",
  SHELTER_VISIT: "Shelter Visit",
  CONTRACT: "Contract",
  ANIMAL_PICKUP: "Animal Pickup",
};

const STATUS_COLORS: Record<StepStatus, string> = {
  PENDING: "yellow",
  IN_PROGRESS: "blue",
  COMPLETED: "green",
  REJECTED: "red",
};

const STATUS_LABELS: Record<StepStatus, string> = {
  PENDING: "Pending",
  IN_PROGRESS: "In Progress",
  COMPLETED: "Completed",
  REJECTED: "Rejected",
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
  return (
    <Card
      radius="md"
      padding="lg"
      style={{ border: `1px solid ${AppColors.divider}` }}
    >
      <Stack gap="md">
        <Group justify="space-between" align="center">
          <Text fw={700} size="lg" style={{ color: AppColors.textDark }}>
            {STEP_LABELS[type]}
          </Text>
          <Badge variant="light" color={STATUS_COLORS[status]} size="md">
            {STATUS_LABELS[status]}
          </Badge>
        </Group>

        {finish_date && (
          <Text size="sm" style={{ color: AppColors.textSecondary }}>
            Completed on{" "}
            {new Date(finish_date).toLocaleDateString(undefined, {
              year: "numeric",
              month: "long",
              day: "numeric",
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
            title="Rejection reason"
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
