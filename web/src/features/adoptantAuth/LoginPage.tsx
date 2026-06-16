import { useState, useEffect } from "react";
import { TextInput, Button, Title, Text, Alert, Stack } from "@mantine/core";
import { useSearchParams } from "react-router-dom";
import { adoptantAuthRepository } from "./data/adoptantAuthRepository";
import FallingPaws from "./components/FallingPaws";
import { useLocalization } from "../../localization/localization";

const MAX_ILLUSTRATIONS = 16;

export default function LoginPage() {
  const { t } = useLocalization();
  const [searchParams] = useSearchParams();
  const reason = searchParams.get("reason");
  const redirect = searchParams.get("redirect");

  useEffect(() => {
    if (redirect) {
      sessionStorage.setItem("auth_redirect", redirect);
    }
  }, [redirect]);

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<
    "idle" | "loading" | "success" | "error"
  >("idle");
  const [loginBg, setLoginBg] = useState<string>("");

  useEffect(() => {
    const randomNum = Math.floor(Math.random() * MAX_ILLUSTRATIONS) + 1;
    import(`../../assets/images/Illustration-${randomNum}.svg`).then(
      (module) => {
        setLoginBg(module.default);
      },
    );
  }, []);

  const handleSubmit = async () => {
    setStatus("loading");
    try {
      await adoptantAuthRepository.requestAccess({ name, email });
      setStatus("success");
    } catch (error) {
      setStatus("error");
    }
  };

  return (
    <div className="flex min-h-[calc(100vh-70px)]">
      <div className="hidden md:flex md:w-1/2 items-center justify-center p-12 bg-background relative overflow-hidden">
        <FallingPaws count={18} />
        {loginBg && (
          <img
            src={loginBg}
            alt={t("auth.loginIllustrationAlt")}
            className="w-72 lg:w-96 h-auto object-contain relative z-10"
          />
        )}
      </div>

      <div className="w-full md:w-1/2 flex items-center justify-center p-8 sm:p-12 lg:p-24 bg-surface">
        <div className="w-full max-w-md">
          {status === "success" ? (
            <div className="text-center">
              <Title order={2} className="text-primary mb-4">
                {t("auth.checkEmail")}
              </Title>
              <Text className="text-text-secondary text-lg">
                {t("auth.loginLinkSent", { email })}
                <br />
                <br />
                {t("auth.loginLinkInstructions")}
              </Text>
            </div>
          ) : (
            <>
              <Title
                order={2}
                className="text-text-dark mb-4 text-center md:text-left"
              >
                {t("auth.welcome")}
              </Title>
              <Text
                mb={40}
                className="text-text-secondary text-center md:text-left"
              >
                {t("auth.enterDetails")}
              </Text>

              {reason === "expired" && (
                <Alert
                  color="warning"
                  mb="xl"
                  className="bg-warning/10 text-warning"
                >
                  {t("auth.sessionExpired")}
                </Alert>
              )}

              {status === "error" && (
                <Alert color="error" mb="xl" className="bg-error/10 text-error">
                  {t("auth.requestError")}
                </Alert>
              )}

              <form
                onSubmit={(e) => {
                  e.preventDefault();
                  handleSubmit();
                }}
              >
                <Stack gap="md">
                  <TextInput
                    label={t("auth.yourName")}
                    size="md"
                    radius="md"
                    value={name}
                    onChange={(e) => setName(e.currentTarget.value)}
                    required
                  />
                  <TextInput
                    label={t("auth.emailAddress")}
                    type="email"
                    size="md"
                    radius="md"
                    value={email}
                    onChange={(e) => setEmail(e.currentTarget.value)}
                    required
                  />
                  <Button
                    type="submit"
                    fullWidth
                    mt="xl"
                    size="md"
                    radius="md"
                    loading={status === "loading"}
                  >
                    {t("auth.sendLoginEmail")}
                  </Button>
                </Stack>
              </form>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
