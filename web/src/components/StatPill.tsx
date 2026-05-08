import { Group, ThemeIcon, Text } from "@mantine/core";
import { AppColors } from "../theme/constants";

interface StatPillProps {
  icon: React.ReactNode;
  label: string;
  color?: string;
  bg?: string;
}

export default function StatPill({
  icon,
  label,
  color = "primary",
  bg = AppColors.primaryTint,
}: StatPillProps) {
  return (
    <Group
      gap={8}
      style={{
        background: bg,
        borderRadius: 999,
        padding: "8px 16px",
        display: "inline-flex",
      }}
    >
      <ThemeIcon size={20} radius="xl" color={color} variant="transparent">
        {icon}
      </ThemeIcon>
      <Text size="sm" fw={500} c={color}>
        {label}
      </Text>
    </Group>
  );
}
