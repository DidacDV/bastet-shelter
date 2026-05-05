import { AppConfig } from "../config";
import { STORAGE_TOKEN_KEY, STORAGE_NAME_KEY } from "../constants";

export class HttpError extends Error {
  public response: Response;

  constructor(message: string, response: Response) {
    super(message);
    this.name = "HttpError";
    this.response = response;
  }
}

async function fetchClient<T>(
  endpoint: string,
  customConfig: RequestInit = {},
): Promise<T | null> {
  const url = `${AppConfig.baseUrl}${endpoint}`;

  const token = localStorage.getItem(STORAGE_TOKEN_KEY);

  const config: RequestInit = {
    ...customConfig,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...customConfig.headers,
    },
  };

  const response = await fetch(url, config);

  if (response.status === 401) {
    localStorage.removeItem(STORAGE_TOKEN_KEY);
    localStorage.removeItem(STORAGE_NAME_KEY);
    window.location.href = "/login?reason=expired";
    throw new HttpError("Session expired", response);
  }

  if (!response.ok) {
    throw new HttpError(`HTTP error! status: ${response.status}`, response);
  }

  if (response.status === 204) {
    return null;
  }

  return (await response.json()) as T;
}

const apiClient = {
  get: <T>(endpoint: string, customConfig?: RequestInit): Promise<T | null> =>
    fetchClient<T>(endpoint, { ...customConfig, method: "GET" }),

  post: <T>(
    endpoint: string,
    body?: unknown,
    customConfig?: RequestInit,
  ): Promise<T | null> =>
    fetchClient<T>(endpoint, {
      ...customConfig,
      method: "POST",
      body: JSON.stringify(body),
    }),

  put: <T>(
    endpoint: string,
    body?: unknown,
    customConfig?: RequestInit,
  ): Promise<T | null> =>
    fetchClient<T>(endpoint, {
      ...customConfig,
      method: "PUT",
      body: JSON.stringify(body),
    }),
  patch: <T>(
    endpoint: string,
    body?: unknown,
    customConfig?: RequestInit,
  ): Promise<T | null> =>
    fetchClient<T>(endpoint, {
      ...customConfig,
      method: "PATCH",
      body: JSON.stringify(body),
    }),
  delete: <T>(
    endpoint: string,
    customConfig?: RequestInit,
  ): Promise<T | null> =>
    fetchClient<T>(endpoint, { ...customConfig, method: "DELETE" }),
};

export default apiClient;
