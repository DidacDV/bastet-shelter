import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { Center, Loader, Text } from "@mantine/core";
import { animalRepository } from "./data/animalsRepository";
import { useLocalization } from "../../localization/localization";

export default function AdoptEntryPage() {
  const { shelterName, animalName } = useParams<{
    shelterName: string;
    animalName: string;
  }>();
  const navigate = useNavigate();
  const { t } = useLocalization();
  const [error, setError] = useState(false);

  useEffect(() => {
    if (!shelterName || !animalName) {
      setError(true);
      return;
    }

    animalRepository
      .getAnimalByLinkName(shelterName, animalName)
      .then((animal) => {
        navigate(`/animals/${animal.id}?intent=adopt`, { replace: true });
      })
      .catch(() => setError(true));
  }, [animalName, navigate, shelterName]);

  if (error) {
    return (
      <Center style={{ minHeight: "60vh", flexDirection: "column", gap: 12 }}>
        <Text c="dimmed">{t("animals.adoptLinkNotFound")}</Text>
      </Center>
    );
  }

  return (
    <Center style={{ minHeight: "60vh" }}>
      <Loader color="primary" />
    </Center>
  );
}
