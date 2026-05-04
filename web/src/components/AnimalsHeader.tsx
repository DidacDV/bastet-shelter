import { Container, Group, Title, Text } from "@mantine/core";
import { AppColors } from "../theme/constants";

export default function AnimalsHeader() {
  return (
    <div>
      <Container size="lg" py="xl">
        <Group justify="space-between" align="flex-end">
          <div>
            <Title order={2} style={{ color: AppColors.textDark, marginBottom: 8 }}>
              Available Animals
            </Title>
            <Text c="dimmed">
              Meet the animals looking for a forever home in this province.
            </Text>
          </div>
        </Group>
      </Container>
    </div>
  );
}