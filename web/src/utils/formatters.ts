import type { TranslationKey } from "../localization/localization";

type Translate = (
  key: TranslationKey,
  params?: Record<string, string | number>,
) => string;

export function formatAge(birthDate: string, t?: Translate): string {
  const birth = new Date(birthDate);
  const now = new Date();
  const years = now.getFullYear() - birth.getFullYear();
  const months = now.getMonth() - birth.getMonth();
  const totalMonths = years * 12 + months;

  if (totalMonths < 1) {
    return t?.("animals.lessThanMonthOld") ?? "Less than a month old";
  }
  if (totalMonths < 12)
    return totalMonths === 1
      ? (t?.("animals.oneMonthOld") ?? "1 month old")
      : (t?.("animals.monthsOld", { count: totalMonths }) ??
          `${totalMonths} months old`);
  if (years === 1) return t?.("animals.oneYearOld") ?? "1 year old";
  return t?.("animals.yearsOld", { count: years }) ?? `${years} years old`;
}

export function formatDate(dateStr: string, locale = "en"): string {
  return new Date(dateStr).toLocaleDateString(locale, {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}
