import { Fragment } from "react";
import { Box, Stack, ThemeIcon, Text, Divider } from "@mantine/core";
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
} from "../data/adoptionTypes";
import { AppColors } from "../../../theme/constants";
import { useLocalization } from "../../../localization/localization";
import { stepTypeKey } from "../../../localization/localizedMappers";

const STEP_ICONS: Record<StepType, React.ReactNode> = {
  FORM: <IconFileDescription size={14} />,
  INTERVIEW: <IconUsers size={14} />,
  SHELTER_VISIT: <IconHome size={14} />,
  CONTRACT: <IconWriting size={14} />,
  ANIMAL_PICKUP: <IconPaw size={14} />,
};

const ICON_ROW_HEIGHT = 28;

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
  const { t } = useLocalization();
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
        {t("adoption.progress")}
      </Text>

      <div
        style={{
          display: "flex",
          alignItems: "flex-start",
          width: "100%",
        }}
      >
        {sorted.map((step, i) => {
          const isCurrent = step.order === currentOrder;
          const color = stepIconColor(step.status, isCurrent);

          return (
            <Fragment key={step.type}>
              <Stack
                align="center"
                gap={4}
                style={{ flex: "1 1 0", minWidth: 0 }}
              >
                <ThemeIcon
                  size="md"
                  radius="xl"
                  color={color}
                  variant={isCurrent ? "filled" : "light"}
                  style={{ flexShrink: 0 }}
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
                    wordBreak: "break-word",
                  }}
                >
                  {t(stepTypeKey(step.type, true))}
                </Text>
              </Stack>

              {i < sorted.length - 1 && (
                <Box
                  style={{
                    flex: "1 1 0",
                    minWidth: 0,
                    height: ICON_ROW_HEIGHT,
                    display: "flex",
                    alignItems: "center",
                    paddingInline: 4,
                  }}
                >
                  <Divider
                    style={{ width: "100%" }}
                    color={
                      step.status === "COMPLETED"
                        ? AppColors.reddish
                        : AppColors.divider
                    }
                  />
                </Box>
              )}
            </Fragment>
          );
        })}
      </div>
    </div>
  );
}
