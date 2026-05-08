import { useState } from "react";
import {
  Modal,
  Stack,
  Title,
  Text,
  Select,
  Switch,
  Textarea,
  NumberInput,
  Button,
  Group,
  Divider,
  Box,
} from "@mantine/core";
import { IconHeart } from "@tabler/icons-react";
import { AppColors } from "../../../theme/constants";

export interface AdoptionFormData {
  housing_type?: string;
  has_garden?: boolean;
  has_other_pets?: boolean;
  other_pets_description?: string;
  has_children?: boolean;
  children_ages?: string;
  previous_pet_experience?: boolean;
  hours_alone_per_day?: number;
  reason_for_adoption?: string;
}

interface AdoptionFormModalProps {
  opened: boolean;
  onClose: () => void;
  animalName: string;
  onSubmit: (data: AdoptionFormData) => Promise<void>;
}

function SectionLabel({ children }: { children: React.ReactNode }) {
  return (
    <Text
      size="xs"
      fw={600}
      tt="uppercase"
      style={{ color: AppColors.textHint, letterSpacing: "0.06em" }}
    >
      {children}
    </Text>
  );
}

export default function AdoptionFormModal({
  opened,
  onClose,
  animalName,
  onSubmit,
}: AdoptionFormModalProps) {
  const [form, setForm] = useState<AdoptionFormData>({});
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const set = <K extends keyof AdoptionFormData>(
    key: K,
    value: AdoptionFormData[K],
  ) => setForm((prev) => ({ ...prev, [key]: value }));

  const handleSubmit = async () => {
    setSubmitting(true);
    setError(null);
    try {
      await onSubmit(form);
      setForm({});
      onClose();
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleClose = () => {
    if (submitting) return;
    setForm({});
    setError(null);
    onClose();
  };

  return (
    <Modal
      opened={opened}
      onClose={handleClose}
      centered
      size="lg"
      radius="md"
      title={
        <Group gap="sm">
          <IconHeart size={18} color={AppColors.primary} />
          <Title order={4} style={{ color: AppColors.textDark }}>
            Adopt {animalName}
          </Title>
        </Group>
      }
      overlayProps={{ backgroundOpacity: 0.4, blur: 3 }}
      styles={{
        header: {
          borderBottom: `1px solid ${AppColors.divider}`,
          paddingBottom: 16,
          marginBottom: 0,
        },
        body: { padding: "24px 24px 20px" },
      }}
    >
      <Text size="sm" c="dimmed" mb="xl">
        Tell us a bit about yourself and your home. All fields are optional —
        just fill in what applies to you.
      </Text>

      <Stack gap="xl">
        <Stack gap="md">
          <SectionLabel>Your home</SectionLabel>

          <Select
            label="Type of housing"
            placeholder="Select..."
            value={form.housing_type ?? null}
            onChange={(v) => set("housing_type", v ?? undefined)}
            data={[
              { value: "apartment", label: "Apartment" },
              { value: "house", label: "House" },
              { value: "house_with_garden", label: "House with garden" },
              { value: "rural", label: "Rural / farm" },
              { value: "other", label: "Other" },
            ]}
            radius="md"
            clearable
            styles={{ input: { borderColor: AppColors.outline } }}
          />

          <Group gap="xl">
            <Switch
              label="I have a garden or outdoor space"
              checked={form.has_garden ?? false}
              onChange={(e) => set("has_garden", e.currentTarget.checked)}
              color="primary"
            />
          </Group>
        </Stack>

        <Divider color={AppColors.divider} />

        <Stack gap="md">
          <SectionLabel>Your household</SectionLabel>

          <Switch
            label="I have children at home"
            checked={form.has_children ?? false}
            onChange={(e) => set("has_children", e.currentTarget.checked)}
            color="primary"
          />

          {form.has_children && (
            <Box
              style={{
                background: AppColors.tintedBg,
                borderRadius: 8,
                padding: "12px 16px",
                border: `1px solid ${AppColors.divider}`,
              }}
            >
              <Text size="xs" c="dimmed" mb={8}>
                Ages of children (e.g. 4, 8, 12)
              </Text>
              <input
                value={form.children_ages ?? ""}
                onChange={(e) =>
                  set("children_ages", e.target.value || undefined)
                }
                placeholder="e.g. 4, 8, 12"
                style={{
                  width: "100%",
                  border: `1px solid ${AppColors.outline}`,
                  borderRadius: 6,
                  padding: "8px 10px",
                  fontSize: 14,
                  color: AppColors.textDark,
                  background: AppColors.pureWhite,
                  outline: "none",
                }}
              />
            </Box>
          )}

          <Switch
            label="I have other pets"
            checked={form.has_other_pets ?? false}
            onChange={(e) => set("has_other_pets", e.currentTarget.checked)}
            color="primary"
          />

          {form.has_other_pets && (
            <Box
              style={{
                background: AppColors.tintedBg,
                borderRadius: 8,
                padding: "12px 16px",
                border: `1px solid ${AppColors.divider}`,
              }}
            >
              <Textarea
                label="Tell us about your other pets"
                placeholder="e.g. 1 adult cat, very calm"
                value={form.other_pets_description ?? ""}
                onChange={(e) =>
                  set(
                    "other_pets_description",
                    e.currentTarget.value || undefined,
                  )
                }
                radius="md"
                autosize
                minRows={2}
                styles={{
                  input: {
                    borderColor: AppColors.outline,
                    background: AppColors.pureWhite,
                  },
                }}
              />
            </Box>
          )}
        </Stack>

        <Divider color={AppColors.divider} />

        <Stack gap="md">
          <SectionLabel>Experience & routine</SectionLabel>

          <Switch
            label="I have previous experience with pets"
            checked={form.previous_pet_experience ?? false}
            onChange={(e) =>
              set("previous_pet_experience", e.currentTarget.checked)
            }
            color="primary"
          />

          <NumberInput
            label="Hours the animal would be alone per day"
            placeholder="e.g. 4"
            value={form.hours_alone_per_day ?? ""}
            onChange={(v) =>
              set("hours_alone_per_day", typeof v === "number" ? v : undefined)
            }
            min={0}
            max={24}
            radius="md"
            styles={{ input: { borderColor: AppColors.outline } }}
          />
        </Stack>

        <Divider color={AppColors.divider} />

        <Textarea
          label="Why do you want to adopt?"
          placeholder="Tell us what motivated you to adopt..."
          value={form.reason_for_adoption ?? ""}
          onChange={(e) =>
            set("reason_for_adoption", e.currentTarget.value || undefined)
          }
          radius="md"
          autosize
          minRows={3}
          styles={{ input: { borderColor: AppColors.outline } }}
        />

        {error && (
          <Text size="sm" style={{ color: AppColors.error }}>
            {error}
          </Text>
        )}

        <Group justify="flex-end" gap="sm" pt={4}>
          <Button
            variant="subtle"
            color="primary"
            onClick={handleClose}
            disabled={submitting}
          >
            Cancel
          </Button>
          <Button
            color="primary"
            radius="md"
            loading={submitting}
            leftSection={<IconHeart size={15} />}
            onClick={handleSubmit}
          >
            Send adoption request
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
