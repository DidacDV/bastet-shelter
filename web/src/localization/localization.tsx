import {
  createContext,
  type ReactNode,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";

import caMessages from "./locales/ca.json";
import enMessages from "./locales/en.json";

const dictionaries = {
  en: enMessages,
  ca: caMessages,
  es: enMessages,
} satisfies Record<string, typeof enMessages>;

export type AppLocale = keyof typeof dictionaries;
export type TranslationKey = keyof typeof enMessages;

const defaultLocale: AppLocale = "en";
const localeStorageKey = "app_locale";

type LocalizationContextValue = {
  locale: AppLocale;
  setLocale: (locale: AppLocale) => void;
  t: (key: TranslationKey, params?: Record<string, string | number>) => string;
};

const LocalizationContext = createContext<LocalizationContextValue | null>(null);

function isSupportedLocale(locale: string | null): locale is AppLocale {
  return locale === "en" || locale === "ca" || locale === "es";
}

function getInitialLocale(): AppLocale {
  const savedLocale = window.localStorage.getItem(localeStorageKey);
  if (isSupportedLocale(savedLocale)) {
    return savedLocale;
  }

  const browserLocale = window.navigator.language.split("-")[0];
  return isSupportedLocale(browserLocale) ? browserLocale : defaultLocale;
}

export function LocalizationProvider({ children }: { children: ReactNode }) {
  const [locale, setLocaleState] = useState<AppLocale>(getInitialLocale);

  useEffect(() => {
    document.documentElement.lang = locale;
    document.title = dictionaries[locale]["app.title"];
  }, [locale]);

  const value = useMemo<LocalizationContextValue>(() => {
    const setLocale = (nextLocale: AppLocale) => {
      window.localStorage.setItem(localeStorageKey, nextLocale);
      setLocaleState(nextLocale);
    };

    const t = (
      key: TranslationKey,
      params: Record<string, string | number> = {},
    ) => {
      let value =
        dictionaries[locale][key] ?? dictionaries[defaultLocale][key] ?? key;
      Object.entries(params).forEach(([paramKey, paramValue]) => {
        value = value.replaceAll(`{${paramKey}}`, String(paramValue));
      });
      return value;
    };

    return { locale, setLocale, t };
  }, [locale]);

  return (
    <LocalizationContext.Provider value={value}>
      {children}
    </LocalizationContext.Provider>
  );
}

export function useLocalization() {
  const context = useContext(LocalizationContext);
  if (!context) {
    throw new Error("useLocalization must be used within LocalizationProvider");
  }
  return context;
}

export const supportedLocales = [
  { code: "en", labelKey: "language.english" },
  { code: "ca", labelKey: "language.catalan" },
  { code: "es", labelKey: "language.spanish" },
] as const;
