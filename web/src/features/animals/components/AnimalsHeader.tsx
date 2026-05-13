import {
  Container,
  Group,
  Title,
  Text,
  TextInput,
  SegmentedControl,
  Center,
} from "@mantine/core";
import {
  IconCat,
  IconClipboardCheck,
  IconDog,
  IconDots,
  IconSearch,
} from "@tabler/icons-react";
import { AppColors } from "../../../theme/constants";
import { useNavigate } from "react-router-dom";
import ProvinceSelect from "../../locations/components/ProvinceSelect";

export type AnimalTypeFilter = "ALL" | "CAT" | "DOG" | "OTHER";

interface AnimalsHeaderProps {
  provinceId: string | null;
  search: string;
  onSearchChange: (value: string) => void;
  typeFilter: AnimalTypeFilter;
  onTypeFilterChange: (value: AnimalTypeFilter) => void;
  totalResults: number;
}

export default function AnimalsHeader({
  provinceId,
  search,
  onSearchChange,
  typeFilter,
  onTypeFilterChange,
  totalResults,
}: AnimalsHeaderProps) {
  const navigate = useNavigate();

  const handleProvinceChange = (value: string | null) => {
    if (value) navigate(`/animals?province=${value}`);
  };

  return (
    <div
      style={{
        borderBottom: `1px solid ${AppColors.divider}`,
        background: AppColors.pureWhite,
      }}
    >
      <Container size="lg" py="xl">
        <Group justify="space-between" align="flex-start" mb="xs">
          <div>
            <Title
              order={2}
              style={{ color: AppColors.textDark, marginBottom: 4 }}
            >
              Available Animals
            </Title>
            <Text c="dimmed">
              Meet the animals looking for a forever home in this province.
            </Text>
          </div>

          <ProvinceSelect
            value={provinceId}
            onChange={handleProvinceChange}
            size="sm"
            radius="md"
            placeholder="Province..."
            style={{ width: 200 }}
            styles={{
              input: { borderColor: AppColors.outline },
            }}
          />
        </Group>

        <Group align="center" gap="md" wrap="wrap">
          <TextInput
            placeholder="Search by name or shelter..."
            value={search}
            onChange={(e) => onSearchChange(e.currentTarget.value)}
            leftSection={<IconSearch size={16} color={AppColors.textHint} />}
            radius="xl"
            size="md"
            style={{ flex: 1, minWidth: 220 }}
            styles={{
              input: { borderColor: AppColors.outline },
            }}
          />

          <SegmentedControl
            value={typeFilter}
            onChange={(v) => onTypeFilterChange(v as AnimalTypeFilter)}
            radius="xl"
            size="md"
            data={[
              {
                label: (
                  <Center style={{ gap: 10 }}>
                    <IconClipboardCheck size={16} />
                    <span>All</span>
                  </Center>
                ),
                value: "ALL",
              },
              {
                label: (
                  <Center style={{ gap: 10 }}>
                    <IconCat size={16} />
                    <span>Cat</span>
                  </Center>
                ),
                value: "CAT",
              },
              {
                label: (
                  <Center style={{ gap: 10 }}>
                    <IconDog size={16} />
                    <span>Dog</span>
                  </Center>
                ),
                value: "DOG",
              },
              {
                label: (
                  <Center style={{ gap: 10 }}>
                    <IconDots size={16} />
                    <span>Other</span>
                  </Center>
                ),
                value: "OTHER",
              },
            ]}
            styles={{
              root: {
                background: AppColors.tintedBg,
                border: `1px solid ${AppColors.outline}`,
              },
            }}
          />
        </Group>

        <Text size="sm" c="dimmed" mt="sm">
          {totalResults === 0
            ? "No animals found"
            : totalResults === 1
              ? "1 animal found"
              : `${totalResults} animals found`}
        </Text>
      </Container>
    </div>
  );
}
