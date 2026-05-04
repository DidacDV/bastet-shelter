import { useEffect, useState } from "react";
import { useSearchParams, Link } from "react-router-dom";
import { Title, Text, Loader, Center, SimpleGrid, Container, Stack, Button } from "@mantine/core";
import { IconAlertCircle } from "@tabler/icons-react";
import { animalRepository, type AnimalPublicShortInfo } from "../features/animals/animalsRepository";
import { AppColors } from "../theme/constants";
import AnimalsHeader from "../components/AnimalsHeader";
import AnimalCard from "../components/AnimalCard";

export default function AnimalsPage() {
  const [searchParams] = useSearchParams();
  const provinceId = searchParams.get("province");

  const [animals, setAnimals] = useState<AnimalPublicShortInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

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

  if (!provinceId) {
    return (
      <Center style={{ minHeight: "calc(100vh - 70px)", background: AppColors.tintedBg }}>
        <Stack align="center">
          <IconAlertCircle size={48} color={AppColors.warning} />
          <Title order={3} style={{ color: AppColors.textDark }}>
            No location selected
          </Title>
          <Button component={Link} to="/" variant="light">
            Go back to location selection
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
      <AnimalsHeader />

      <Container size="lg" py="xl">
        {loading ? (
          <Center py={100}>
            <Loader color="primary" />
          </Center>
        ) : error ? (
          <Center py={100}>
            <Text c="red">Something went wrong while fetching the animals.</Text>
          </Center>
        ) : animals.length === 0 ? (
          <Center py={100} style={{ flexDirection: "column", gap: 16 }}>
            <Text size="lg" fw={500} c="dimmed">
              No animals found in this province right now.
            </Text>
            <Button component={Link} to="/" variant="light">
              Check another province
            </Button>
          </Center>
        ) : (
          <SimpleGrid cols={{ base: 1, sm: 2, md: 3, lg: 4 }} spacing="lg">
            {animals.map((animal) => (
              <AnimalCard key={animal.id} animal={animal} />
            ))}
          </SimpleGrid>
        )}
      </Container>
    </div>
  );
}