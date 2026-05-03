import { useState, useEffect } from "react";
import { TextInput, Button, Title, Text, Alert, Stack } from "@mantine/core";
import { useSearchParams } from "react-router-dom";
import { adoptantAuthRepository } from "../features/adoptantAuth/adoptantAuthRepository";
import FallingPaws from "../components/FallingPaws";

const MAX_ILLUSTRATIONS = 16;

export default function LoginPage() {
  const [searchParams] = useSearchParams();
  const reason = searchParams.get("reason");

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<
    "idle" | "loading" | "success" | "error"
  >("idle");
  const [loginBg, setLoginBg] = useState<string>("");

  useEffect(() => {
    const randomNum = Math.floor(Math.random() * MAX_ILLUSTRATIONS) + 1;
    import(`../assets/images/Illustration-${randomNum}.svg`).then((module) => {
      setLoginBg(module.default);
    });
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
            alt="Login illustration"
            className="w-72 lg:w-96 h-auto object-contain relative z-10"
          />
        )}
      </div>

      <div className="w-full md:w-1/2 flex items-center justify-center p-8 sm:p-12 lg:p-24 bg-surface">
        <div className="w-full max-w-md">
          {status === "success" ? (
            <div className="text-center">
              <Title order={2} className="text-primary mb-4">
                Check your email
              </Title>
              <Text className="text-text-secondary text-lg">
                We've sent a secure magic link to <strong>{email}</strong>.
                <br />
                <br />
                Click the link in the email to securely log in and continue your
                adoption journey.
              </Text>
            </div>
          ) : (
            <>
              <Title
                order={2}
                className="text-text-dark mb-4 text-center md:text-left"
              >
                Welcome to BastetShelter
              </Title>
              <Text
                mb={40}
                className="text-text-secondary text-center md:text-left"
              >
                Enter your details to receive a secure login link.
              </Text>

              {reason === "expired" && (
                <Alert
                  color="warning"
                  mb="xl"
                  className="bg-warning/10 text-warning"
                >
                  Your session expired. Please request a new link.
                </Alert>
              )}

              {status === "error" && (
                <Alert color="error" mb="xl" className="bg-error/10 text-error">
                  Something went wrong. Please check your email and try again.
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
                    label="Your Name"
                    size="md"
                    radius="md"
                    value={name}
                    onChange={(e) => setName(e.currentTarget.value)}
                    required
                  />
                  <TextInput
                    label="Email Address"
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
                    Send email for login
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
