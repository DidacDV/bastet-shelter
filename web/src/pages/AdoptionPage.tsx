import { useEffect, useState } from "react";
import { Title, Text, Card, Loader, Button, Center } from "@mantine/core";
import { Link } from "react-router-dom";
import { adoptionsRepository } from "../features/adoptions/adoptionRepository";
import type { AdoptionProcessShort } from "../features/adoptions/adoptionTypes";
import AdoptionCard from "../components/AdoptionCard";

export default function AdoptionPage() {
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
        setError("Failed to load your adoptions. Please try again later.");
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
          My Adoptions
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
          You don't have any active adoption processes yet.
        </Text>
        <Button component={Link} to="/animals" color="primary" size="md">
          Find a Pet to Adopt
        </Button>
      </Center>
    );
  }

  return (
    <div className="max-w-5xl mx-auto py-8 px-4">
      <Title mb={8} order={2} className="text-text-dark">
        My Adoptions
      </Title>
      <Text mb={16} className="text-text-secondary">
        Click on an adoption card to view details and track your process
      </Text>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {adoptions.map((adoption) => (
          <AdoptionCard key={adoption.id} adoption={adoption} />
        ))}
      </div>
    </div>
  );
}
