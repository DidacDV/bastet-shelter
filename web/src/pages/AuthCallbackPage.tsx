import { useEffect, useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { Loader, Text, Stack } from "@mantine/core";
import { adoptantAuthRepository } from "../features/adoptantAuth/adoptantAuthRepository";
import { useAuth } from "../context/authContext";

export default function AuthCallbackPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { login } = useAuth();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const processMagicLink = async () => {
      const token = searchParams.get("token");

      if (!token) {
        setError("No token found in the URL.");
        return;
      }

      try {
        const result = await adoptantAuthRepository.verifyToken(token);

        if (result) {
          login(result.access_token, result.adoptant_name);

          //check redirect
          const redirect = searchParams.get("redirect") || "/adoption";
          navigate(redirect, { replace: true });
        }
      } catch (err) {
        setError("Invalid or expired magic link. Please try logging in again.");
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
          Go back to Login
        </Text>
      </Stack>
    );
  }

  return (
    <Stack align="center" justify="center" className="min-h-[60vh]">
      <Loader color="primary" size="lg" />
      <Text c="text-secondary">Verifying your secure link...</Text>
    </Stack>
  );
}
