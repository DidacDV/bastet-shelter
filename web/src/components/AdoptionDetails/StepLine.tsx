import { Group, Stack, ThemeIcon, Text, Divider } from "@mantine/core";
import {
  IconFileDescription,
  IconUsers,
  IconHome,
  IconWriting,
  IconPaw,
} from "@tabler/icons-react";
import type {
  AdoptionStepSummary,
  StepStatus,
  StepType,
} from "../../features/adoptions/adoptionTypes";
import { AppColors } from "../../theme/constants";

const STEP_ICONS: Record<StepType, React.ReactNode> = {
  FORM: <IconFileDescription size={14} />,
  INTERVIEW: <IconUsers size={14} />,
  SHELTER_VISIT: <IconHome size={14} />,
  CONTRACT: <IconWriting size={14} />,
  ANIMAL_PICKUP: <IconPaw size={14} />,
};

const STEP_LABELS: Record<StepType, string> = {
  FORM: "Form",
  INTERVIEW: "Interview",
  SHELTER_VISIT: "Shelter Visit",
  CONTRACT: "Contract",
  ANIMAL_PICKUP: "Pickup",
};

function stepIconColor(status: StepStatus, isCurrent: boolean) {
  if (isCurrent) return AppColors.primary;
  if (status === "COMPLETED") return AppColors.reddish;
  if (status === "REJECTED") return AppColors.error;
  return AppColors.textHint;
}

export default function StepTimeline({
  steps,
  currentOrder,
}: {
  steps: AdoptionStepSummary[];
  currentOrder: number | null;
}) {
  const sorted = [...steps].sort((a, b) => a.order - b.order);

  return (
    <div style={{ marginBottom: 12 }}>
      <Text
        size="xs"
        fw={600}
        tt="uppercase"
        style={{ color: AppColors.textHint, letterSpacing: "0.08em" }}
        mb="md"
      >
        Progress
      </Text>
      <Group gap={0} align="center" wrap="nowrap">
        {sorted.map((step, i) => {
          const isCurrent = step.order === currentOrder;
          const color = stepIconColor(step.status, isCurrent);

          return (
            <Group
              key={step.type}
              gap={0}
              align="center"
              wrap="nowrap"
              style={{ flex: 1 }}
            >
              <Stack align="center" gap={4} style={{ minWidth: 52 }}>
                <ThemeIcon
                  size="md"
                  radius="xl"
                  color={color}
                  variant={isCurrent ? "filled" : "light"}
                >
                  {STEP_ICONS[step.type]}
                </ThemeIcon>
                <Text
                  size="xs"
                  ta="center"
                  fw={isCurrent ? 700 : 400}
                  style={{
                    color: isCurrent
                      ? AppColors.textDark
                      : AppColors.textSecondary,
                    lineHeight: 1.2,
                  }}
                >
                  {STEP_LABELS[step.type]}
                </Text>
              </Stack>

              {i < sorted.length - 1 && (
                <Divider
                  style={{ flex: 1 }}
                  color={
                    step.status === "COMPLETED"
                      ? AppColors.reddish
                      : AppColors.divider
                  }
                />
              )}
            </Group>
          );
        })}
      </Group>
    </div>
  );
}
