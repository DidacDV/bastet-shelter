import apiClient from "../../core/network/apiClient";

interface RequestAccessPayload {
  name: string;
  email: string;
}

interface VerifyResponse {
  access_token: string;
  token_type: string;
  adoptant_name: string;
}

export const adoptantAuthRepository = {
  requestAccess: (data: RequestAccessPayload) =>
    apiClient.post<{ message: string }>("/adoption-auth/request-access", data),

  verifyToken: (token: string) =>
    apiClient.get<VerifyResponse>(`/adoption-auth/verify?token=${token}`),
};
