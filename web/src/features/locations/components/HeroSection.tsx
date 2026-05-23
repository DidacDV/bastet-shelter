import { Title, Text, Stack, Group } from "@mantine/core";
import { IconMapPin, IconHeart } from "@tabler/icons-react";
import { AppColors } from "../../../theme/constants";
import StatPill from "../../../components/StatPill";
import { useLocalization } from "../../../localization/localization";

import Illustration1 from "../../../assets/images/Illustration-1.svg";
import Illustration2 from "../../../assets/images/Illustration-2.svg";
import Illustration3 from "../../../assets/images/Illustration-10.svg";
import Illustration4 from "../../..//assets/images/Illustration-19.svg";

export default function HeroSection() {
  const { t } = useLocalization();

  return (
    <div
      style={{
        padding: "56px 0 0px",
        overflow: "hidden",
      }}
    >
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "1fr auto 1fr",
          alignItems: "center",
          maxWidth: 1100,
          margin: "0 auto",
          padding: "0 24px",
          gap: 146,
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "flex-end",
            gap: 16,
          }}
        >
          <img
            src={Illustration1}
            alt=""
            style={{
              width: "clamp(100px, 14vw, 180px)",
              opacity: 0.92,
              transform: "rotate(-6deg) translateY(8px)",
            }}
          />
          <img
            src={Illustration2}
            alt=""
            style={{
              width: "clamp(80px, 11vw, 150px)",
              opacity: 0.78,
              transform: "rotate(4deg) translateX(-12px)",
            }}
          />
        </div>

        <Stack
          align="center"
          gap="lg"
          style={{ textAlign: "center", minWidth: 0 }}
        >
          <div>
            <Title
              order={1}
              style={{
                color: AppColors.pureWhite,
                fontSize: "clamp(1.6rem, 3.5vw, 2.6rem)",
                fontWeight: 700,
                lineHeight: 1.2,
              }}
            >
              {t("home.heroTitle")}
            </Title>
            <Text
              mt="sm"
              style={{
                color: "rgba(255,255,255,0.75)",
                maxWidth: 420,
                fontSize: "clamp(0.9rem, 1.5vw, 1.05rem)",
                lineHeight: 1.6,
              }}
            >
              {t("home.heroSubtitle")}
            </Text>
          </div>

          <Group gap="sm" justify="center">
            <StatPill
              icon={<IconHeart size={14} />}
              label={t("home.animalsLooking")}
            />
            <StatPill
              icon={<IconMapPin size={14} />}
              label={t("home.sheltersAcrossSpain")}
            />
          </Group>
        </Stack>

        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "flex-start",
            gap: 16,
          }}
        >
          <img
            src={Illustration3}
            alt=""
            style={{
              width: "clamp(80px, 11vw, 150px)",
              opacity: 0.78,
              transform: "rotate(-4deg) translateX(12px)",
            }}
          />
          <img
            src={Illustration4}
            alt=""
            style={{
              width: "clamp(100px, 14vw, 180px)",
              opacity: 0.92,
              transform: "rotate(6deg) translateY(8px)",
            }}
          />
        </div>
      </div>
    </div>
  );
}
