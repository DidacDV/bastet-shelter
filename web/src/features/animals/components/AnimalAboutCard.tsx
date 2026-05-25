import { Stack, Box, Title, Text, Group, Badge } from "@mantine/core";
import { AppColors } from "../../../theme/constants";
import { type AnimalPublicDetails } from "../data/animalsRepository";
import { LAYOUT_CONSTANTS } from "../data/constants";
import { useLocalization } from "../../../localization/localization";

export default function AnimalAboutCard({
  animal,
}: {
  animal: AnimalPublicDetails;
}) {
  const { t } = useLocalization();

  const cardStyle = {
    background: AppColors.pureWhite,
    borderRadius: LAYOUT_CONSTANTS.CARD_RADIUS,
    padding: LAYOUT_CONSTANTS.CARD_PADDING,
    border: `1px solid ${AppColors.divider}`,
  };

  return (
    <Stack gap="xl">
      <Box style={cardStyle}>
        <Title order={4} mb="md" style={{ color: AppColors.textDark }}>
          {t("animals.aboutAnimal", { animal: animal.name })}
        </Title>
        <Text
          size="sm"
          style={{ color: AppColors.textSecondary, lineHeight: 1.7 }}
        >
          {animal.description || t("animals.noDescription")}
        </Text>
      </Box>

      {animal.traits.length > 0 && (
        <Box style={cardStyle}>
          <Title order={4} mb="md" style={{ color: AppColors.textDark }}>
            {t("animals.personality")}
          </Title>
          <Group gap="xs">
            {animal.traits.map((trait) => (
              <Badge
                key={trait.id}
                variant="light"
                color="secondary"
                radius="xl"
                size="md"
              >
                {trait.name}
              </Badge>
            ))}
          </Group>
        </Box>
      )}
    </Stack>
  );
}
