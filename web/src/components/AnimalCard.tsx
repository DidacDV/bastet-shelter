import { Card, Image, Stack, Group, Text, Badge } from "@mantine/core";
import { IconMapPin } from "@tabler/icons-react";
import { type AnimalPublicShortInfo } from "../features/animals/animalsRepository";
import { AppColors } from "../theme/constants";
import { Link } from "react-router-dom";

export default function AnimalCard({
  animal,
}: {
  animal: AnimalPublicShortInfo;
}) {
  return (
    <Link to={`/animals/${animal.id}`}>
      <Card
        padding="none"
        radius="md"
        className="group transition-all duration-300 ease-out hover:-translate-y-1 hover:shadow-[0_12px_24px_rgba(0,0,0,0.05)] cursor-pointer"
        style={{
          border: `1px solid ${AppColors.divider}`,
        }}
      >
        <Card.Section className="overflow-hidden">
          <Image
            src={
              animal.image_url || "https://placehold.co/600x400?text=No+Photo"
            }
            height={220}
            alt={animal.name}
            fallbackSrc="https://placehold.co/600x400?text=No+Photo"
            className="transition-transform duration-500 ease-out group-hover:scale-120"
          />
        </Card.Section>

        <Stack p="md" gap="xs">
          <Group justify="space-between" align="center" wrap="nowrap">
            <Text
              fw={700}
              size="lg"
              style={{
                color: AppColors.textDark,
                overflow: "hidden",
                textOverflow: "ellipsis",
                whiteSpace: "nowrap",
              }}
            >
              {animal.name}
            </Text>
            <Badge variant="light" color="primary">
              {animal.age === 0
                ? "< 1 year"
                : animal.age === 1
                  ? "1 year"
                  : `${animal.age} years`}
            </Badge>
          </Group>

          <Group gap={6} wrap="nowrap">
            <IconMapPin
              size={14}
              color={AppColors.textHint}
              style={{ flexShrink: 0 }}
            />
            <Text
              size="sm"
              style={{
                color: AppColors.textSecondary,
                overflow: "hidden",
                textOverflow: "ellipsis",
                whiteSpace: "nowrap",
              }}
            >
              {animal.shelter_name} • {animal.refuge_name}
            </Text>
          </Group>
        </Stack>
      </Card>
    </Link>
  );
}
