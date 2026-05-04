import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { Container, Loader, Center, Button, Box, Text } from "@mantine/core";
import { IconArrowLeft, IconHeart } from "@tabler/icons-react";
import {
  animalRepository,
  type AnimalPublicDetails,
} from "../features/animals/animalsRepository";
import { AppColors } from "../theme/constants";
import { useAuth } from "../context/authContext";
import { LAYOUT_CONSTANTS } from "../features/animals/constants";

import PhotoGrid from "../components/PhotoGrid";
import AnimalDetailHeader from "../components/AnimalDetailsHeader";
import AnimalAboutCard from "../components/AnimalAboutCard";
import AnimalDetailsCard from "../components/AnimalDetailsCard";
import ImageViewerModal from "../components/ImageViewerModal";
import AdoptionFormModal from "../components/AdoptionFormModal";
import { adoptionsRepository } from "../features/adoptions/adoptionRepository";
import type { AdoptionFormSubmit } from "../features/adoptions/adoptionTypes";

export default function AnimalDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { isLoggedIn } = useAuth();

  const [animal, setAnimal] = useState<AnimalPublicDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [viewerImage, setViewerImage] = useState<string | null>(null);
  const [adoptionModalOpen, setAdoptionModalOpen] = useState(false);

  useEffect(() => {
    if (!id) return;
    animalRepository
      .getAnimalDetails(Number(id))
      .then(setAnimal)
      .catch(() => setError(true))
      .finally(() => setLoading(false));
  }, [id]);

  const handleAdopt = () => {
    if (!isLoggedIn) {
      navigate(`/login?redirect=/animals/${animal?.id}`);
    } else {
      setAdoptionModalOpen(true);
    }
  };

  if (loading) {
    return (
      <Center
        style={{ minHeight: `calc(100vh - ${LAYOUT_CONSTANTS.HEADER_OFFSET})` }}
      >
        <Loader color="primary" />
      </Center>
    );
  }

  if (error || !animal) {
    return (
      <Center
        style={{
          minHeight: `calc(100vh - ${LAYOUT_CONSTANTS.HEADER_OFFSET})`,
          flexDirection: "column",
          gap: 16,
        }}
      >
        <Text c="dimmed">Animal not found or something went wrong.</Text>
        <Button variant="light" onClick={() => navigate(-1)}>
          Go back
        </Button>
      </Center>
    );
  }
  const handleAdoptionSubmit = async (data: AdoptionFormSubmit) => {
    await adoptionsRepository.startAdoption(animal.id, data);
    navigate("/my-adoptions");
  };
  return (
    <>
      <div
        style={{
          minHeight: `calc(100vh - ${LAYOUT_CONSTANTS.HEADER_OFFSET})`,
          background: AppColors.background,
          paddingBottom: LAYOUT_CONSTANTS.PAGE_BOTTOM_PADDING,
        }}
      >
        <PhotoGrid
          images={animal.images}
          name={animal.name}
          onImageClick={setViewerImage}
        />

        <Container size="md" pt="sm">
          <Button
            variant="subtle"
            color="primary"
            leftSection={<IconArrowLeft size={16} />}
            onClick={() => navigate(-1)}
            mb="lg"
            px={0}
          >
            Back to animals
          </Button>

          <AnimalDetailHeader
            animal={animal}
            onAdopt={handleAdopt}
            isLoggedIn={isLoggedIn}
          />

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "1fr 1fr",
              gap: LAYOUT_CONSTANTS.GRID_GAP,
              alignItems: "start",
            }}
          >
            <AnimalAboutCard animal={animal} />
            <AnimalDetailsCard animal={animal} />
          </div>

          {animal.in_adoption && (
            <Box mt="xl" hiddenFrom="sm">
              <Button
                fullWidth
                size="md"
                radius="md"
                color="primary"
                leftSection={<IconHeart size={16} />}
                onClick={handleAdopt}
              >
                {isLoggedIn
                  ? `Adopt ${animal.name}`
                  : `Quickly log in to adopt ${animal.name}`}
              </Button>
            </Box>
          )}
        </Container>
      </div>
      <ImageViewerModal
        imageUrl={viewerImage}
        onClose={() => setViewerImage(null)}
      />
      <AdoptionFormModal
        opened={adoptionModalOpen}
        onClose={() => setAdoptionModalOpen(false)}
        animalName={animal.name}
        onSubmit={handleAdoptionSubmit}
      />
    </>
  );
}
