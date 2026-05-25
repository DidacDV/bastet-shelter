import { Box, Title, Group, Text } from "@mantine/core";
import { IconCalendar } from "@tabler/icons-react";
import { AppColors } from "../../../theme/constants";
import { type AnimalPublicDetails } from "../data/animalsRepository";
import { LAYOUT_CONSTANTS } from "../data/constants";
import { formatAge, formatDate } from "../../../utils/formatters";
import { useLocalization } from "../../../localization/localization";
import { animalTypeKey } from "../../../localization/localizedMappers";

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <Group
      justify="space-between"
      py="sm"
      style={{ borderBottom: `1px solid ${AppColors.divider}` }}
    >
      <Text size="sm" c="dimmed">
        {label}
      </Text>
      <Text size="sm" fw={500} style={{ color: AppColors.textDark }}>
        {value}
      </Text>
    </Group>
  );
}

export default function AnimalDetailsCard({
  animal,
}: {
  animal: AnimalPublicDetails;
}) {
  const { locale, t } = useLocalization();

  return (
    <Box
      style={{
        background: AppColors.pureWhite,
        borderRadius: LAYOUT_CONSTANTS.CARD_RADIUS,
        padding: LAYOUT_CONSTANTS.CARD_PADDING,
        border: `1px solid ${AppColors.divider}`,
      }}
    >
      <Title order={4} mb="md" style={{ color: AppColors.textDark }}>
        {t("animals.details")}
      </Title>

      <InfoRow label={t("animals.age")} value={formatAge(animal.birth_date, t)} />
      <InfoRow label={t("animals.breed")} value={animal.breed || t("common.unknown")} />
      <InfoRow
        label={t("animals.type")}
        value={t(animalTypeKey(animal.animal_type))}
      />
      <InfoRow label={t("animals.shelter")} value={animal.shelter_name} />
      <InfoRow label={t("animals.refuge")} value={animal.refuge_name} />

      {animal.arrival_date && (
        <InfoRow
          label={t("animals.atShelterSince")}
          value={formatDate(animal.arrival_date, locale)}
        />
      )}

      <Group gap={6} mt={LAYOUT_CONSTANTS.GRID_GAP}>
        <IconCalendar size={14} color={AppColors.textHint} />
        <Text size="xs" c="dimmed">
          {t("animals.born", { date: formatDate(animal.birth_date, locale) })}
        </Text>
      </Group>

      {!animal.in_adoption && (
        <Box
          mt="md"
          style={{
            background: AppColors.warningTint,
            borderRadius: 8,
            padding: "10px 14px",
          }}
        >
          <Text size="xs" fw={500} style={{ color: AppColors.deepOrange }}>
            {t("animals.notCurrentlyAvailable")}
          </Text>
        </Box>
      )}
    </Box>
  );
}
