import { useEffect, useState } from "react";
import { Title, Text, Card, Loader, Button, Center } from "@mantine/core";
import { Link } from "react-router-dom";
import { adoptionsRepository } from "./data/adoptionRepository";
import type { AdoptionProcessShort } from "./data/adoptionTypes";
import AdoptionCard from "./components/AdoptionCard";
import { useLocalization } from "../../localization/localization";

export default function AdoptionPage() {
  const { t } = useLocalization();
  const [adoptions, setAdoptions] = useState<AdoptionProcessShort[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchAdoptions = async () => {
      try {
        const data = await adoptionsRepository.getMyAdoptions();

        const adoptionsList = Array.isArray(data)
          ? data
          : data?.processes || [];
        setAdoptions(adoptionsList);
      } catch (err) {
        console.error(err);
        setError(t("adoption.loadMineError"));
      } finally {
        setLoading(false);
      }
    };

    fetchAdoptions();
  }, []);

  if (loading) {
    return (
      <Center style={{ minHeight: "calc(100vh - 70px)" }}>
        <Loader color="primary" type="dots" />
      </Center>
    );
  }

  if (error) {
    return (
      <div className="max-w-5xl mx-auto py-8 px-4">
        <Title order={2} className="text-text-dark mb-1">
          {t("header.myAdoptions")}
        </Title>
        <Card className="bg-error/10 border-error/20 p-6 text-center mt-6">
          <Text className="text-error font-medium">{error}</Text>
        </Card>
      </div>
    );
  }

  //empty state
  if (adoptions.length === 0) {
    return (
      <Center
        style={{
          minHeight: "calc(100vh - 70px)",
          flexDirection: "column",
          gap: 16,
        }}
      >
        <Text size="lg" className="text-text-secondary">
          {t("adoption.emptyMine")}
        </Text>
        <Button component={Link} to="/animals" color="primary" size="md">
          {t("adoption.findPetToAdopt")}
        </Button>
      </Center>
    );
  }

  return (
    <div className="max-w-5xl mx-auto py-8 px-4">
      <Title mb={8} order={2} className="text-text-dark">
        {t("header.myAdoptions")}
      </Title>
      <Text mb={16} className="text-text-secondary">
        {t("adoption.mineSubtitle")}
      </Text>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {adoptions.map((adoption) => (
          <AdoptionCard key={adoption.id} adoption={adoption} />
        ))}
      </div>
    </div>
  );
}
