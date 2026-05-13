import { Group, Title, Badge, Text, Button } from "@mantine/core";
import { IconMapPin, IconHeart, IconEye } from "@tabler/icons-react";
import { AppColors } from "../../../theme/constants";
import { type AnimalPublicDetails } from "../data/animalsRepository";
import { LAYOUT_CONSTANTS, ANIMAL_TYPE_LABEL } from "../data/constants";

interface AnimalHeaderProps {
  animal: AnimalPublicDetails;
  onAdoptClick: () => void;
  isLoggedIn: boolean;
  hasExistingProcess: boolean;
}

export default function AnimalDetailHeader({
  animal,
  onAdoptClick,
  isLoggedIn,
  hasExistingProcess,
}: AnimalHeaderProps) {
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

      {animal.in_adoption && (
        <Button
          size="md"
          radius="md"
          color="primary"
          leftSection={
            hasExistingProcess ? <IconEye size={16} /> : <IconHeart size={16} />
          }
          onClick={onAdoptClick}
          style={{ flexShrink: 0 }}
          visibleFrom="sm"
        >
          {hasExistingProcess
            ? `View your adoption process with ${animal.name}`
            : isLoggedIn
              ? `Adopt ${animal.name}`
              : `Quickly log in to adopt ${animal.name}`}
        </Button>
      )}
    </Group>
  );
}
