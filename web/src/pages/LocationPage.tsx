import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Title,
  Text,
  Select,
  Button,
  Loader,
  Center,
  Stack,
  Box,
  Group,
} from "@mantine/core";
import { IconMapPin, IconArrowRight } from "@tabler/icons-react";
import { geoRepository, type Province } from "../features/locations/locationRepository";
import { AppColors } from "../theme/constants";
import HeroSection from "../components/HeroSection";

export default function LocationPage() {
  const navigate = useNavigate();

  const [provinces, setProvinces] = useState<Province[]>([]);
  const [selected, setSelected] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    geoRepository
      .getProvinces()
      .then((res) => setProvinces(res ? res.provinces : []))
      .catch(() => setError(true))
      .finally(() => setLoading(false));
  }, []);

  const handleContinue = () => {
    if (selected) navigate(`/animals?province=${selected}`);
  };

  const provinceOptions = provinces.map((p) => ({
    value: p.id,
    label: p.name,
  }));

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
                Where are you located?
              </Title>
            </Group>
            <Text size="sm" c="dimmed" ml={28}>
              Select your province to see animals from nearby shelters.
            </Text>
          </Stack>

          {loading ? (
            <Center py="xl">
              <Loader color="primary" size="sm" />
            </Center>
          ) : error ? (
            <Text c="red" size="sm" ta="center" py="md">
              Couldn't load provinces. Please refresh and try again.
            </Text>
          ) : (
            <Stack gap="md">
              <Select
                placeholder="Select a province..."
                data={provinceOptions}
                value={selected}
                onChange={setSelected}
                searchable
                size="md"
                radius="md"
                leftSection={<IconMapPin size={16} color={AppColors.textHint} />}
                styles={{
                  input: {
                    borderColor: AppColors.outline,
                  },
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
                See available animals
              </Button>
            </Stack>
          )}
        </Box>
      </Center>
    </div>
  );
}