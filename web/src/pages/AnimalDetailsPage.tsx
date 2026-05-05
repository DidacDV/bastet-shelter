import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { Container, Loader, Center, Button, Box, Text } from "@mantine/core";
import { IconArrowLeft, IconHeart, IconEye } from "@tabler/icons-react";
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

  const [hasExistingProcess, setHasExistingProcess] = useState(false);
  const [existingProcessId, setExistingProcessId] = useState<number | null>(
    null,
  );

  useEffect(() => {
    if (!id) return;
    animalRepository
      .getAnimalDetails(Number(id))
      .then(setAnimal)
      .catch(() => setError(true))
      .finally(() => setLoading(false));
  }, [id]);

  useEffect(() => {
    if (isLoggedIn && animal) {
      adoptionsRepository.getMyAdoptions().then((res) => {
        if (res) {
          const adoptionsList = Array.isArray(res) ? res : res.processes || [];

          const activeProcess = adoptionsList.find(
            (p) =>
              p.animal_id === animal.id &&
              p.status !== "REJECTED" &&
              p.status !== "CANCELLED",
          );

          setHasExistingProcess(!!activeProcess);
          setExistingProcessId(activeProcess?.id || null);
        }
      });
    }
  }, [isLoggedIn, animal]);

  const handleActionClick = () => {
    if (hasExistingProcess) {
      navigate(`/adoptions/${existingProcessId}`);
    } else if (!isLoggedIn) {
      navigate(`/login?redirect=/animals/${animal?.id}`);
    } else {
      setAdoptionModalOpen(true);
    }
  };

  const handleAdoptionSubmit = async (data: AdoptionFormSubmit) => {
    await adoptionsRepository.startAdoption(animal!.id, data);
    navigate("/adoptions");
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
            onAdoptClick={handleActionClick}
            isLoggedIn={isLoggedIn}
            hasExistingProcess={hasExistingProcess}
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
                leftSection={
                  hasExistingProcess ? (
                    <IconEye size={16} />
                  ) : (
                    <IconHeart size={16} />
                  )
                }
                onClick={handleActionClick}
              >
                {hasExistingProcess
                  ? `View your adoption process with ${animal.name}`
                  : isLoggedIn
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
