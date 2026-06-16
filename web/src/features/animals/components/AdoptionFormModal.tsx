import { useState } from "react";
import {
  Modal,
  Stack,
  Title,
  Text,
  Select,
  Switch,
  Textarea,
  TextInput,
  NumberInput,
  Button,
  Group,
  Divider,
  Box,
  Input,
} from "@mantine/core";
import { IconHeart } from "@tabler/icons-react";
import { AppColors } from "../../../theme/constants";
import { useLocalization } from "../../../localization/localization";

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

const INITIAL_FORM: AdoptionFormData = {
  has_garden: false,
  has_children: false,
  has_other_pets: false,
  previous_pet_experience: false,
};

type FieldErrors = Partial<Record<keyof AdoptionFormData, string>>;

export default function AdoptionFormModal({
  opened,
  onClose,
  animalName,
  onSubmit,
}: AdoptionFormModalProps) {
  const { t } = useLocalization();
  const [form, setForm] = useState<AdoptionFormData>(INITIAL_FORM);
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({});
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const requiredMessage = t("adoption.form.fieldRequired");

  const set = <K extends keyof AdoptionFormData>(
    key: K,
    value: AdoptionFormData[K],
  ) => {
    setForm((prev) => ({ ...prev, [key]: value }));
    setFieldErrors((prev) => {
      if (!prev[key]) return prev;
      const next = { ...prev };
      delete next[key];
      return next;
    });
  };

  const validate = (): FieldErrors => {
    const errors: FieldErrors = {};

    if (!form.housing_type) {
      errors.housing_type = requiredMessage;
    }
    if (form.hours_alone_per_day === undefined) {
      errors.hours_alone_per_day = requiredMessage;
    }
    if (!form.reason_for_adoption?.trim()) {
      errors.reason_for_adoption = requiredMessage;
    }
    if (form.has_children && !form.children_ages?.trim()) {
      errors.children_ages = requiredMessage;
    }
    if (form.has_other_pets && !form.other_pets_description?.trim()) {
      errors.other_pets_description = requiredMessage;
    }

    return errors;
  };

  const handleSubmit = async () => {
    const errors = validate();
    if (Object.keys(errors).length > 0) {
      setFieldErrors(errors);
      return;
    }

    setSubmitting(true);
    setError(null);
    try {
      await onSubmit(form);
      setForm(INITIAL_FORM);
      setFieldErrors({});
      onClose();
    } catch {
      setError(t("common.tryAgainError"));
    } finally {
      setSubmitting(false);
    }
  };

  const handleClose = () => {
    if (submitting) return;
    setForm(INITIAL_FORM);
    setFieldErrors({});
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
            {t("adoption.form.adoptAnimal", { animal: animalName })}
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
        {t("adoption.form.intro")}
      </Text>

      <Stack gap="xl">
        <Stack gap="md">
          <SectionLabel>{t("adoption.form.yourHome")}</SectionLabel>

          <Select
            label={t("adoption.form.housingType")}
            placeholder={t("common.select")}
            value={form.housing_type ?? null}
            onChange={(v) => set("housing_type", v ?? undefined)}
            data={[
              { value: "apartment", label: t("adoption.form.housing.apartment") },
              { value: "house", label: t("adoption.form.housing.house") },
              { value: "house_with_garden", label: t("adoption.form.housing.houseWithGarden") },
              { value: "rural", label: t("adoption.form.housing.rural") },
              { value: "other", label: t("adoption.form.housing.other") },
            ]}
            radius="md"
            withAsterisk
            error={fieldErrors.housing_type}
            styles={{ input: { borderColor: AppColors.outline } }}
          />

          <Input.Wrapper label={t("adoption.form.hasGarden")} withAsterisk>
            <Switch
              checked={form.has_garden ?? false}
              onChange={(e) => set("has_garden", e.currentTarget.checked)}
              color="primary"
              mt={4}
            />
          </Input.Wrapper>
        </Stack>

        <Divider color={AppColors.divider} />

        <Stack gap="md">
          <SectionLabel>{t("adoption.form.yourHousehold")}</SectionLabel>

          <Input.Wrapper label={t("adoption.form.hasChildren")} withAsterisk>
            <Switch
              checked={form.has_children ?? false}
              onChange={(e) => {
                const checked = e.currentTarget.checked;
                set("has_children", checked);
                if (!checked) {
                  set("children_ages", undefined);
                }
              }}
              color="primary"
              mt={4}
            />
          </Input.Wrapper>

          {form.has_children && (
            <Box
              style={{
                background: AppColors.tintedBg,
                borderRadius: 8,
                padding: "12px 16px",
                border: `1px solid ${AppColors.divider}`,
              }}
            >
              <TextInput
                label={t("adoption.form.childrenAgesLabel")}
                placeholder={t("adoption.form.childrenAgesHint")}
                value={form.children_ages ?? ""}
                onChange={(e) =>
                  set("children_ages", e.currentTarget.value || undefined)
                }
                withAsterisk
                error={fieldErrors.children_ages}
                radius="md"
                styles={{
                  input: {
                    borderColor: AppColors.outline,
                    background: AppColors.pureWhite,
                  },
                }}
              />
            </Box>
          )}

          <Input.Wrapper label={t("adoption.form.hasOtherPets")} withAsterisk>
            <Switch
              checked={form.has_other_pets ?? false}
              onChange={(e) => {
                const checked = e.currentTarget.checked;
                set("has_other_pets", checked);
                if (!checked) {
                  set("other_pets_description", undefined);
                }
              }}
              color="primary"
              mt={4}
            />
          </Input.Wrapper>

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
                label={t("adoption.form.otherPetsDescription")}
                placeholder={t("adoption.form.otherPetsHint")}
                value={form.other_pets_description ?? ""}
                onChange={(e) =>
                  set(
                    "other_pets_description",
                    e.currentTarget.value || undefined,
                  )
                }
                withAsterisk
                error={fieldErrors.other_pets_description}
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
          <SectionLabel>{t("adoption.form.experienceRoutine")}</SectionLabel>

          <Input.Wrapper label={t("adoption.form.previousExperience")} withAsterisk>
            <Switch
              checked={form.previous_pet_experience ?? false}
              onChange={(e) =>
                set("previous_pet_experience", e.currentTarget.checked)
              }
              color="primary"
              mt={4}
            />
          </Input.Wrapper>

          <NumberInput
            label={t("adoption.form.hoursAlone")}
            placeholder={t("adoption.form.hoursAloneHint")}
            value={form.hours_alone_per_day ?? ""}
            onChange={(v) =>
              set("hours_alone_per_day", typeof v === "number" ? v : undefined)
            }
            min={0}
            max={24}
            radius="md"
            withAsterisk
            error={fieldErrors.hours_alone_per_day}
            styles={{ input: { borderColor: AppColors.outline } }}
          />
        </Stack>

        <Divider color={AppColors.divider} />

        <Textarea
          label={t("adoption.form.reason")}
          placeholder={t("adoption.form.reasonHint")}
          value={form.reason_for_adoption ?? ""}
          onChange={(e) =>
            set("reason_for_adoption", e.currentTarget.value || undefined)
          }
          radius="md"
          autosize
          minRows={3}
          withAsterisk
          error={fieldErrors.reason_for_adoption}
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
            {t("common.cancel")}
          </Button>
          <Button
            color="primary"
            radius="md"
            loading={submitting}
            leftSection={<IconHeart size={15} />}
            onClick={handleSubmit}
          >
            {t("adoption.form.sendRequest")}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
