import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Title, Text, Button, Center, Stack, Box, Group } from "@mantine/core";
import { IconMapPin, IconArrowRight } from "@tabler/icons-react";
import { AppColors } from "../../theme/constants";
import HeroSection from "./components/HeroSection";
import ProvinceSelect from "./components/ProvinceSelect";
import { useLocalization } from "../../localization/localization";

export default function LocationPage() {
  const navigate = useNavigate();
  const { t } = useLocalization();
  const [selected, setSelected] = useState<string | null>(null);

  const handleContinue = () => {
    if (selected) navigate(`/animals?province=${selected}`);
  };

  return (
    <div
      style={{
        minHeight: "calc(100vh - 70px)",
        background: AppColors.tintedBg,
        display: "flex",
        flexDirection: "column",
      }}
    >
      <HeroSection />

      <Center style={{ flex: 1, padding: "12px 14px" }}>
        <Box
          style={{
            background: AppColors.pureWhite,
            borderRadius: 16,
            padding: "40px 36px",
            width: "100%",
            maxWidth: 460,
            boxShadow: "0 4px 32px rgba(59,54,134,0.08)",
            border: `1px solid ${AppColors.divider}`,
          }}
        >
          <Stack gap="xs" mb={24}>
            <Group gap={8}>
              <IconMapPin size={20} color={AppColors.primary} />
              <Title
                order={3}
                style={{ color: AppColors.textDark, fontSize: "1.2rem" }}
              >
                {t("location.title")}
              </Title>
            </Group>
            <Text size="sm" c="dimmed" ml={28}>
              {t("location.subtitle")}
            </Text>
          </Stack>

          <Stack gap="md">
            <ProvinceSelect
              placeholder={t("location.selectProvince")}
              value={selected}
              onChange={setSelected}
              size="md"
              radius="md"
              styles={{
                input: { borderColor: AppColors.outline },
              }}
            />

            <Button
              fullWidth
              size="md"
              radius="md"
              color="primary"
              disabled={!selected}
              rightSection={<IconArrowRight size={16} />}
              onClick={handleContinue}
            >
              {t("location.seeAvailableAnimals")}
            </Button>
          </Stack>
        </Box>
      </Center>
    </div>
  );
}
