import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { Stack, Title, Text, Loader, Alert } from "@mantine/core";
import { IconAlertCircle } from "@tabler/icons-react";
import { adoptionsRepository } from "./data/adoptionRepository";
import type {
  AdoptionProcessAdoptantResponse,
  ContractStep,
} from "./data/adoptionTypes";
import { AppColors } from "../../theme/constants";

import StepTimeline from "./components/StepLine";
import CurrentStepView from "./components/CurrentStep";
import { useLocalization } from "../../localization/localization";

export default function AdoptionDetailPage() {
  const { id } = useParams<{ id: string }>();
  const processId = Number(id);
  const { locale, t } = useLocalization();

  const [process, setProcess] =
    useState<AdoptionProcessAdoptantResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetch = async () => {
      try {
        const data = await adoptionsRepository.getAdoptionDetail(processId);
        setProcess(data);
      } catch {
        setError(t("adoption.loadProcessError"));
      } finally {
        setLoading(false);
      }
    };
    fetch();
  }, [processId]);

  const handleContractSigned = (updated: ContractStep) => {
    if (!process) return;
    setProcess({ ...process, current_step: updated });
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Loader color={AppColors.primary} type="dots" />
      </div>
    );
  }

  if (error || !process) {
    return (
      <div className="max-w-2xl mx-auto py-8 px-4">
        <Alert
          icon={<IconAlertCircle size={16} />}
          color={AppColors.error}
          variant="light"
        >
          {error ?? t("adoption.processNotFound")}
        </Alert>
      </div>
    );
  }

  const isRejected =
    process.status === "REJECTED" || process.status === "CANCELLED";

  return (
    <div className="max-w-2xl mx-auto py-8 px-4">
      <Stack gap="xl">
        <Stack gap={4}>
          <Title order={2} style={{ color: AppColors.textDark }}>
            {process.animal_name}
          </Title>
          <Text size="sm" style={{ color: AppColors.textSecondary }}>
            {t("adoption.processStartedOn", {
              date: new Date(process.start_date).toLocaleDateString(locale, {
              year: "numeric",
              month: "long",
              day: "numeric",
              }),
            })}
          </Text>
        </Stack>

        {isRejected && (
          <Alert
            icon={<IconAlertCircle size={16} />}
            color={AppColors.error}
            variant="light"
            title={
              process.status === "CANCELLED"
                ? t("adoption.processCancelled")
                : t("adoption.applicationRejected")
            }
          >
            {process.rejection_reason ??
              t("adoption.closedMessage")}
          </Alert>
        )}

        {process.steps.length > 0 && (
          <StepTimeline
            steps={process.steps}
            currentOrder={process.current_step?.order ?? null}
          />
        )}

        {!isRejected && process.current_step ? (
          <Stack gap="xs">
            <Text
              size="xs"
              fw={600}
              tt="uppercase"
              style={{ color: AppColors.textHint, letterSpacing: "0.08em" }}
            >
              {t("adoption.currentStep")}
            </Text>
            <CurrentStepView
              step={process.current_step}
              processId={processId}
              onContractSigned={handleContractSigned}
            />
            <Text
              size="sm"
              mt="sm"
              fs="italic"
              style={{ color: AppColors.textSecondary }}
            >
              {t("adoption.moreInfoEmail")}
            </Text>
          </Stack>
        ) : !isRejected ? (
          <Text size="sm" style={{ color: AppColors.textSecondary }}>
            {t("adoption.allStepsCompleted")}
          </Text>
        ) : null}
      </Stack>
    </div>
  );
}
