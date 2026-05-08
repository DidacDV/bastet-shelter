import { Card, Image, Stack, Group, Text, Badge, Center } from "@mantine/core";
import { IconMapPin } from "@tabler/icons-react";
import { type AnimalPublicShortInfo } from "../data/animalsRepository";
import { AppColors } from "../../../theme/constants";
import { Link } from "react-router-dom";
import catPlaceholder from "../../../assets/images/Illustration-8.svg";
import dogPlaceholder from "../../../assets/images/Illustration-1.svg";

export default function AnimalCard({
  animal,
}: {
  animal: AnimalPublicShortInfo;
}) {
  const fallbackImg =
    animal.animal_type === "CAT" ? catPlaceholder : dogPlaceholder;
  const isPlaceholder = !animal.image_url;

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
        <Card.Section
          className="overflow-hidden"
          h={340}
          bg={isPlaceholder ? AppColors.primaryTint : "transparent"}
        >
          {isPlaceholder ? (
            <Center h="100%">
              <Image
                src={fallbackImg}
                h={220}
                w="auto"
                fit="contain"
                alt="No photo available"
                className="transition-transform duration-500 ease-out group-hover:scale-110"
              />
            </Center>
          ) : (
            <Image
              src={animal.image_url}
              fallbackSrc={fallbackImg}
              height={220}
              fit="cover"
              alt={animal.name}
              className="transition-transform duration-500 ease-out group-hover:scale-120"
            />
          )}
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
