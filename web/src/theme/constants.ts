export const AppConstants = {
  defaultProvince: "08", // code for bcn
  defaultPadding: 24, // in pixels
  maxRefuges: 10,
  timeoutDuration: 20, // seconds

  tabsPadding: "12px 24px 16px 24px",
} as const;

export const AppColors = {
  iris: "#3B3686",
  reddish: "#767AE6",
  apricot: "#EDBA40",
  deepOrange: "#E28C33",
  pureOrange: "#E0652B",
  tintedBg: "#F4F5FF",
  pureWhite: "#FFFFFF",
  textDark: "#1F1D45",

  primary: "#3B3686", // iris
  secondary: "#767AE6", // reddish
  accent: "#EDBA40", // apricot
  warning: "#E28C33", // deepOrange
  error: "#E0652B", // pureOrange
  background: "#F4F5FF", // tintedBg
  surface: "#FFFFFF", // pureWhite
  textPrimary: "#1F1D45", // textDark

  textSecondary: "#5A587A",
  textHint: "#9E9CBF",
  outline: "#D0CFEA",
  divider: "#E8E8F5",

  // Tints
  primaryTint: "#ECEBFA",
  secondaryTint: "#E8E9FF",
  accentTint: "#FDF3D6",
  warningTint: "#FDF0E0",
  errorTint: "#FFE8DF",
} as const;

export type AppColor = keyof typeof AppColors;
