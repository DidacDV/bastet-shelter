import { Box, Title, Group, Text } from "@mantine/core";
import { IconCalendar } from "@tabler/icons-react";
import { AppColors } from "../../../theme/constants";
import { type AnimalPublicDetails } from "../data/animalsRepository";
import { LAYOUT_CONSTANTS, ANIMAL_TYPE_LABEL } from "../data/constants";
import { formatAge, formatDate } from "../../../utils/formatters";

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
        Details
      </Title>

      <InfoRow label="Age" value={formatAge(animal.birth_date)} />
      <InfoRow label="Breed" value={animal.breed || "Unknown"} />
      <InfoRow
        label="Type"
        value={ANIMAL_TYPE_LABEL[animal.animal_type] ?? animal.animal_type}
      />
      <InfoRow label="Shelter" value={animal.shelter_name} />
      <InfoRow label="Refuge" value={animal.refuge_name} />

      {animal.arrival_date && (
        <InfoRow
          label="At shelter since"
          value={formatDate(animal.arrival_date)}
        />
      )}

      <Group gap={6} mt={LAYOUT_CONSTANTS.GRID_GAP}>
        <IconCalendar size={14} color={AppColors.textHint} />
        <Text size="xs" c="dimmed">
          Born {formatDate(animal.birth_date)}
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
            This animal is not currently available for adoption.
          </Text>
        </Box>
      )}
    </Box>
  );
}
