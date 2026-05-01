import { createContext, useContext, useState, useEffect } from "react";
import type { ReactNode } from "react";
import { STORAGE_TOKEN_KEY, STORAGE_NAME_KEY } from "../core/constants";

interface AuthContextType {
  token: string | null;
  adoptantName: string | null;
  isLoggedIn: boolean;
  login: (token: string, name: string) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [token, setToken] = useState<string | null>(
    localStorage.getItem(STORAGE_TOKEN_KEY),
  );
  const [adoptantName, setAdoptantName] = useState<string | null>(
    localStorage.getItem(STORAGE_NAME_KEY),
  );

  const login = (newToken: string, name: string) => {
    localStorage.setItem(STORAGE_TOKEN_KEY, newToken);
    localStorage.setItem(STORAGE_NAME_KEY, name);
    setToken(newToken);
    setAdoptantName(name);
  };

  const logout = () => {
    localStorage.removeItem(STORAGE_TOKEN_KEY);
    localStorage.removeItem(STORAGE_NAME_KEY);
    setToken(null);
    setAdoptantName(null);
  };

  return (
    <AuthContext.Provider
      value={{ token, adoptantName, isLoggedIn: !!token, login, logout }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
