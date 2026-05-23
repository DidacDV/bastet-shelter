import { Group, Title, Badge, Text, Button } from "@mantine/core";
import { IconMapPin, IconHeart, IconEye } from "@tabler/icons-react";
import { AppColors } from "../../../theme/constants";
import { type AnimalPublicDetails } from "../data/animalsRepository";
import { LAYOUT_CONSTANTS } from "../data/constants";
import { useLocalization } from "../../../localization/localization";
import { animalTypeKey } from "../../../localization/localizedMappers";

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
  const { t } = useLocalization();

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
            {t(animalTypeKey(animal.animal_type))}
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
            ? t("animals.viewAdoptionWith", { animal: animal.name })
            : isLoggedIn
              ? t("animals.adoptAnimal", { animal: animal.name })
              : t("animals.loginToAdopt", { animal: animal.name })}
        </Button>
      )}
    </Group>
  );
}
