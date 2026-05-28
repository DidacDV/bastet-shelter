import { useEffect, useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { Loader, Text, Stack } from "@mantine/core";
import { adoptantAuthRepository } from "./data/adoptantAuthRepository";
import { useAuth } from "../../context/authContext";
import { useLocalization } from "../../localization/localization";

export default function AuthCallbackPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { login } = useAuth();
  const { t } = useLocalization();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const processMagicLink = async () => {
      const token = searchParams.get("token");

      if (!token) {
        setError(t("auth.noToken"));
        return;
      }

      try {
        const result = await adoptantAuthRepository.verifyToken(token);

        if (result) {
          login(result.access_token, result.adoptant_name);

          const storedRedirect = sessionStorage.getItem("auth_redirect");
          const redirect =
            storedRedirect || searchParams.get("redirect") || "/adoptions";
          sessionStorage.removeItem("auth_redirect");
          navigate(redirect, { replace: true });
        }
      } catch (err) {
        setError(t("auth.invalidMagicLink"));
      }
    };

    processMagicLink();
  }, [searchParams, navigate, login]);

  if (error) {
    return (
      <Stack align="center" justify="center" className="min-h-[60vh]">
        <Text c="error" fw={600}>
          {error}
        </Text>
        <Text
          component="a"
          href="/login"
          c="primary"
          className="hover:underline cursor-pointer"
        >
          {t("auth.backToLogin")}
        </Text>
      </Stack>
    );
  }

  return (
    <Stack align="center" justify="center" className="min-h-[60vh]">
      <Loader color="primary" size="lg" />
      <Text c="text-secondary">{t("auth.verifyingLink")}</Text>
    </Stack>
  );
}
