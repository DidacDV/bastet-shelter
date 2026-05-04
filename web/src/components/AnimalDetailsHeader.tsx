import { Group, Title, Badge, Text, Button } from "@mantine/core";
import { IconMapPin, IconHeart } from "@tabler/icons-react";
import { AppColors } from "../theme/constants";
import { type AnimalPublicDetails } from "../features/animals/animalsRepository";
import {
  LAYOUT_CONSTANTS,
  ANIMAL_TYPE_LABEL,
} from "../features/animals/constants";

interface AnimalDetailsHeaderProps {
  animal: AnimalPublicDetails;
  onAdopt: () => void;
}

export default function AnimalDetailsHeader({
  animal,
  onAdopt,
}: AnimalDetailsHeaderProps) {
  return (
    <Group justify="space-between" align="flex-start" mb="xl" wrap="nowrap">
      <div>
        <Group gap="sm" mb={6} align="center">
          <Title
            order={1}
            style={{
              color: AppColors.textDark,
              fontSize: LAYOUT_CONSTANTS.HERO_NAME_SIZE,
            }}
          >
            {animal.name}
          </Title>
          <Badge color="primary" variant="light" size="lg">
            {ANIMAL_TYPE_LABEL[animal.animal_type] ?? animal.animal_type}
          </Badge>
        </Group>
        <Group gap={6}>
          <IconMapPin size={14} color={AppColors.textHint} />
          <Text size="sm" c="dimmed">
            {animal.shelter_name} · {animal.refuge_name}
          </Text>
        </Group>
      </div>

      <Button
        size="md"
        radius="md"
        color="primary"
        leftSection={<IconHeart size={16} />}
        onClick={onAdopt}
        style={{ flexShrink: 0 }}
        visibleFrom="sm"
      >
        Adopt {animal.name}
      </Button>
    </Group>
  );
}
