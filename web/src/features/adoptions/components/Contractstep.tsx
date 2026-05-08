import { useState } from "react";
import {
  Stack,
  Group,
  Text,
  Button,
  ThemeIcon,
  Alert,
  Anchor,
} from "@mantine/core";
import {
  IconCheck,
  IconClock,
  IconFileText,
  IconSignature,
  IconAlertCircle,
} from "@tabler/icons-react";
import type { ContractStep } from "../data/adoptionTypes";
import { adoptionsRepository } from "../data/adoptionRepository";
import { AppColors } from "../../../theme/constants";
import StepCardBase from "./StepCardBase";

function SignatureRow({ label, signed }: { label: string; signed: boolean }) {
  return (
    <Group gap={10} align="center">
      <ThemeIcon
        size="sm"
        radius="xl"
        color={signed ? "green" : "gray"}
        variant="light"
      >
        {signed ? <IconCheck size={12} /> : <IconClock size={12} />}
      </ThemeIcon>
      <Text size="sm" style={{ color: AppColors.textSecondary }}>
        {label}:{" "}
        <Text
          span
          fw={600}
          style={{
            color: signed ? "var(--mantine-color-green-7)" : AppColors.textDark,
          }}
        >
          {signed ? "Signed" : "Pending"}
        </Text>
      </Text>
    </Group>
  );
}

export default function ContractStepView({
  step,
  processId,
  onSigned,
}: {
  step: ContractStep;
  processId: number;
  onSigned: (updated: ContractStep) => void;
}) {
  const [signing, setSigning] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSign = async () => {
    setSigning(true);
    setError(null);
    try {
      const updated = await adoptionsRepository.signContract(processId);
      if (updated != null) {
        onSigned(updated);
      }
    } catch {
      setError("Something went wrong while signing. Please try again.");
    } finally {
      setSigning(false);
    }
  };

  return (
    <StepCardBase
      type={step.type}
      status={step.status}
      notes={step.notes}
      rejection_reason={step.rejection_reason}
      finish_date={step.finish_date}
    >
      <Stack gap="md">
        {step.contract_url ? (
          <Group gap={8} align="center">
            <IconFileText size={16} color={AppColors.textHint} />
            <Anchor
              href={step.contract_url}
              target="_blank"
              rel="noopener noreferrer"
              size="sm"
              fw={500}
            >
              View Contract PDF
            </Anchor>
          </Group>
        ) : (
          <Group gap={8} align="flex-start">
            <IconFileText
              size={16}
              color={AppColors.textHint}
              style={{ marginTop: 2 }}
            />
            <Text size="sm" style={{ color: AppColors.textSecondary }}>
              The contract document is not yet available. The shelter will
              upload it shortly.
            </Text>
          </Group>
        )}

        <Stack gap={6}>
          <SignatureRow
            label="Your signature"
            signed={step.signed_by_adoptant}
          />
          <SignatureRow
            label="Shelter signature"
            signed={step.signed_by_shelter}
          />
        </Stack>

        {!step.signed_by_adoptant && (
          <Stack gap="xs">
            {error && (
              <Alert
                icon={<IconAlertCircle size={14} />}
                color="red"
                variant="light"
                p="xs"
              >
                {error}
              </Alert>
            )}
            <Button
              leftSection={<IconSignature size={16} />}
              color="primary"
              onClick={handleSign}
              loading={signing}
              disabled={!step.contract_url}
            >
              Sign Contract
            </Button>
            {!step.contract_url && (
              <Text size="xs" style={{ color: AppColors.textHint }}>
                You can sign once the contract document has been uploaded.
              </Text>
            )}
          </Stack>
        )}
      </Stack>
    </StepCardBase>
  );
}
