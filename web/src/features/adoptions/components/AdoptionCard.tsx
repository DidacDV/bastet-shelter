import { Card, Image, Stack, Group, Text, Badge } from "@mantine/core";
import { IconCalendar } from "@tabler/icons-react";
import { type AdoptionProcessShort } from "../data/adoptionTypes";
import { AppColors } from "../../../theme/constants";
import { Link } from "react-router-dom";
import placeholder from "../../../assets/images/paws/paw-cat-pet-svgrepo-com.svg";
import { useLocalization } from "../../../localization/localization";
import { adoptionStatusKey } from "../../../localization/localizedMappers";

const STATUS_COLORS: Record<string, string> = {
  PENDING: AppColors.deepOrange,
  ACTIVE: AppColors.reddish,
  IN_PROGRESS: AppColors.primary,
  APPROVED: AppColors.apricot,
  REJECTED: AppColors.error,
  CANCELLED: AppColors.textHint,
};

export default function AdoptionCard({
  adoption,
}: {
  adoption: AdoptionProcessShort;
}) {
  const { locale, t } = useLocalization();
  const fallbackImg = adoption.animal_image_url || placeholder;
  return (
    <Link to={`/adoptions/${adoption.id}`} style={{ textDecoration: "none" }}>
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
            src={adoption.animal_image_url || fallbackImg}
            height={220}
            alt={adoption.animal_name}
            fallbackSrc={fallbackImg}
            className="transition-transform duration-500 ease-out group-hover:scale-110" //zoom on hover
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
              {adoption.animal_name}
            </Text>
            <Badge
              variant="light"
              color={STATUS_COLORS[adoption.status] ?? AppColors.textHint}
            >
              {t(adoptionStatusKey(adoption.status))}
            </Badge>
          </Group>

          <Group gap={6} wrap="nowrap">
            <IconCalendar
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
              {t("adoption.startedOn", {
                date: new Date(adoption.start_date).toLocaleDateString(locale),
              })}
            </Text>
          </Group>
        </Stack>
      </Card>
    </Link>
  );
}
