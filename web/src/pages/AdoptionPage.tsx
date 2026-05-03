import { useEffect, useState } from "react";
import {
  Title,
  Text,
  Card,
  Badge,
  Group,
  Loader,
  Image,
  Button,
} from "@mantine/core";
import { Link } from "react-router-dom";
import { useAuth } from "../context/authContext";
import {
  adoptionsRepository,
  type AdoptionProcessShort,
} from "../features/adoptions/adoptionRepository";

export default function AdoptionPage() {
  const { adoptantName, logout } = useAuth();

  const [adoptions, setAdoptions] = useState<AdoptionProcessShort[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchAdoptions = async () => {
      try {
        const data = await adoptionsRepository.getMyAdoptions();
        setAdoptions(data || []);
      } catch (err) {
        console.error(err);
        setError("Failed to load your adoptions. Please try again later.");
      } finally {
        setLoading(false);
      }
    };

    fetchAdoptions();
  }, []);

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case "approved":
        return "green";
      case "completed":
        return "primary";
      case "rejected":
        return "error";
      case "interview":
        return "accent";
      default:
        return "warning";
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Loader color="primary" type="dots" />
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto py-8 px-4">
      <Group justify="space-between" align="flex-end" className="mb-8">
        <div>
          <Title order={2} className="text-text-dark mb-1">
            Welcome back, {adoptantName || "Friend"}
          </Title>
          <Text className="text-text-secondary">
            Track your current adoption applications here.
          </Text>
        </div>

        <Button variant="subtle" color="error" onClick={logout}>
          Log Out
        </Button>
      </Group>

      {error ? (
        <Card className="bg-error/10 border-error/20 p-6 text-center">
          <Text className="text-error font-medium">{error}</Text>
        </Card>
      ) : adoptions.length === 0 ? (
        <Card className="p-12 text-center border-divider border-dashed bg-transparent">
          <Text className="text-text-secondary mb-4">
            You don't have any active adoption processes yet.
          </Text>
          <Button component={Link} to="/animals" color="primary">
            Find a Pet to Adopt
          </Button>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {adoptions.map((adoption) => (
            <Card
              key={adoption.id}
              className="hover:shadow-md transition-shadow flex flex-col h-full"
            >
              <Card.Section>
                <Image
                  src={
                    adoption.animal_photo ||
                    "https://placehold.co/400x300?text=No+Photo"
                  }
                  height={160}
                  alt={adoption.animal_name}
                />
              </Card.Section>

              <Group justify="space-between" mt="md" mb="xs">
                <Text fw={600} size="lg" className="text-text-dark">
                  {adoption.animal_name}
                </Text>
                <Badge color={getStatusColor(adoption.status)}>
                  {adoption.status.toUpperCase()}
                </Badge>
              </Group>

              <Text size="sm" className="text-text-secondary mt-auto pt-4">
                Started on {new Date(adoption.start_date).toLocaleDateString()}
              </Text>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
