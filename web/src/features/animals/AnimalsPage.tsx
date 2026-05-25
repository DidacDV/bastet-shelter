import { useEffect, useState, useMemo } from "react";
import { useSearchParams, Link } from "react-router-dom";
import {
  Title,
  Text,
  Loader,
  Center,
  SimpleGrid,
  Container,
  Stack,
  Button,
  Group,
} from "@mantine/core";
import { IconAlertCircle, IconMapPin } from "@tabler/icons-react";
import {
  animalRepository,
  type AnimalPublicShortInfo,
} from "./data/animalsRepository";
import { AppColors } from "../../theme/constants";
import AnimalsHeader, {
  type AnimalTypeFilter,
} from "./components/AnimalsHeader";
import AnimalCard from "./components/AnimalCard";
import { useLocalization } from "../../localization/localization";

export default function AnimalsPage() {
  const { t } = useLocalization();
  const [searchParams, setSearchParams] = useSearchParams();
  const urlProvinceId = searchParams.get("province");

  //store province in localStorage to persist selection across sessions and page reloads
  useEffect(() => {
    const savedProvince = localStorage.getItem("bastet_province");

    if (!urlProvinceId && savedProvince) {
      setSearchParams({ province: savedProvince }, { replace: true });
    } else if (urlProvinceId) {
      localStorage.setItem("bastet_province", urlProvinceId);
    }
  }, [urlProvinceId, setSearchParams]);
  const provinceId = urlProvinceId || localStorage.getItem("bastet_province");

  const [animals, setAnimals] = useState<AnimalPublicShortInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const [search, setSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState<AnimalTypeFilter>("ALL");

  //reset filters when province changes
  useEffect(() => {
    setSearch("");
    setTypeFilter("ALL");
  }, [provinceId]);

  useEffect(() => {
    if (!provinceId) {
      setLoading(false);
      return;
    }
    setLoading(true);
    animalRepository
      .getAnimalsByProvince(provinceId)
      .then((res) => setAnimals(res ? res.animals : []))
      .catch(() => setError(true))
      .finally(() => setLoading(false));
  }, [provinceId]);

  const filtered = useMemo(() => {
    const q = search.toLowerCase().trim();
    return animals.filter((a) => {
      const matchesSearch =
        !q ||
        a.name.toLowerCase().includes(q) ||
        a.shelter_name?.toLowerCase().includes(q) ||
        a.refuge_name?.toLowerCase().includes(q);
      const matchesType = typeFilter === "ALL" || a.animal_type === typeFilter;
      return matchesSearch && matchesType;
    });
  }, [animals, search, typeFilter]);

  if (!provinceId) {
    return (
      <Center
        style={{
          minHeight: "calc(100vh - 70px)",
          background: AppColors.tintedBg,
        }}
      >
        <Stack align="center">
          <IconAlertCircle size={48} color={AppColors.warning} />
          <Title order={3} style={{ color: AppColors.textDark }}>
            {t("animals.noLocationSelected")}
          </Title>
          <Button component={Link} to="/" variant="light">
            {t("animals.backToLocationSelection")}
          </Button>
        </Stack>
      </Center>
    );
  }

  return (
    <div
      style={{
        minHeight: "calc(100vh - 70px)",
        background: AppColors.tintedBg,
        paddingBottom: 64,
      }}
    >
      <AnimalsHeader
        provinceId={provinceId}
        search={search}
        onSearchChange={setSearch}
        typeFilter={typeFilter}
        onTypeFilterChange={setTypeFilter}
        totalResults={filtered.length}
      />

      <Container size="lg" py="xl">
        {loading ? (
          <Center py={100}>
            <Loader color="primary" />
          </Center>
        ) : error ? (
          <Center py={100}>
            <Text c="red">
              {t("animals.fetchError")}
            </Text>
          </Center>
        ) : filtered.length === 0 ? (
          <Center
            py={100}
            style={{ flexDirection: "column", gap: 16, textAlign: "center" }}
          >
            <Text size="lg" fw={500} c="dimmed">
              {animals.length === 0
                ? t("animals.noneAvailableProvince")
                : t("animals.noneMatchSearch")}
            </Text>

            {animals.length === 0 ? (
              <Group gap={8} style={{ color: AppColors.textHint }}>
                <IconMapPin size={18} />
                <Text size="sm">
                  {t("animals.tryDifferentProvince")}
                </Text>
              </Group>
            ) : (
              <Button
                variant="light"
                onClick={() => {
                  setSearch("");
                  setTypeFilter("ALL");
                }}
              >
                {t("animals.clearFilters")}
              </Button>
            )}
          </Center>
        ) : (
          <SimpleGrid cols={{ base: 1, sm: 2, md: 3, lg: 4 }} spacing="lg">
            {filtered.map((animal) => (
              <AnimalCard key={animal.id} animal={animal} />
            ))}
          </SimpleGrid>
        )}
      </Container>
    </div>
  );
}
