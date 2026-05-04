import { Card, Image, Stack, Group, Text, Badge } from "@mantine/core";
import { IconMapPin } from "@tabler/icons-react";
import { type AnimalPublicShortInfo } from "../features/animals/animalsRepository";
import { AppColors } from "../theme/constants";

export default function AnimalCard({ animal }: { animal: AnimalPublicShortInfo }) {
  return (
    <Card
      padding="none"
      radius="md"
      style={{
        border: `1px solid ${AppColors.divider}`,
        transition: "transform 0.2s ease, box-shadow 0.2s ease",
        cursor: "pointer",
        "&:hover": {
          transform: "translateY(-4px)",
          boxShadow: "0 12px 24px rgba(0,0,0,0.05)",
        },
      }}
    >
      <Card.Section>
        <Image
          src={animal.image_url || "https://placehold.co/600x400?text=No+Photo"}
          height={220}
          alt={animal.name}
          fallbackSrc="https://placehold.co/600x400?text=No+Photo"
        />
      </Card.Section>

      <Stack p="md" gap="xs">
        <Group justify="space-between" align="center" wrap="nowrap">
          <Text fw={700} size="lg" style={{ color: AppColors.textDark, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
            {animal.name}
          </Text>
          <Badge variant="light" color="primary">
            {animal.age === 0 ? "< 1 year" : animal.age === 1 ? "1 year" : `${animal.age} years`}
          </Badge>
        </Group>

        <Group gap={6} wrap="nowrap">
          <IconMapPin size={14} color={AppColors.textHint} style={{ flexShrink: 0 }} />
          <Text size="sm" style={{ color: AppColors.textSecondary, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
            {animal.shelter_name} • {animal.refuge_name}
          </Text>
        </Group>
      </Stack>
    </Card>
  );
}