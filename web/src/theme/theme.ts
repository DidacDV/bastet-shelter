import { createTheme, rem } from "@mantine/core";
import { generateColors } from "@mantine/colors-generator";
import { AppColors } from "./constants";

export const theme = createTheme({
  primaryColor: "primary",
  white: AppColors.surface,
  fontFamily: "Inter, system-ui, Avenir, Helvetica, Arial, sans-serif",

  colors: {
    primary: generateColors(AppColors.primary),
    secondary: generateColors(AppColors.secondary),
    accent: generateColors(AppColors.accent),
    warning: generateColors(AppColors.warning),
    error: generateColors(AppColors.error),
  },

  defaultRadius: "md",
  cursorType: "pointer",

  components: {
    Button: {
      defaultProps: {
        color: "primary",
        fw: 600,
      },
      styles: {
        root: {
          transition: "background-color 0.2s ease, transform 0.1s ease",
        },
      },
    },

    Card: {
      defaultProps: {
        radius: "md",
        withBorder: true,
        shadow: "sm",
      },
      styles: {
        root: {
          backgroundColor: AppColors.surface,
          borderColor: AppColors.divider,
        },
      },
    },

    Badge: {
      defaultProps: {
        variant: "light",
        radius: "xl",
        fw: 700,
      },
    },

    //forms stuff
    TextInput: {
      defaultProps: { radius: "md" },
      styles: {
        input: {
          borderColor: AppColors.outline,
          color: AppColors.textPrimary,
          "&:focus": {
            borderColor: AppColors.primary,
          },
          "&::placeholder": {
            color: AppColors.textHint,
          },
        },
        label: {
          color: AppColors.textDark,
          fontWeight: 500,
          marginBottom: rem(4),
        },
      },
    },
    Select: {
      defaultProps: { radius: "md" },
      styles: {
        input: {
          borderColor: AppColors.outline,
          color: AppColors.textPrimary,
        },
        label: {
          color: AppColors.textDark,
          fontWeight: 500,
          marginBottom: rem(4),
        },
      },
    },
    Textarea: {
      defaultProps: { radius: "md" },
      styles: {
        input: { borderColor: AppColors.outline, color: AppColors.textPrimary },
        label: {
          color: AppColors.textDark,
          fontWeight: 500,
          marginBottom: rem(4),
        },
      },
    },

    //texts stuff
    Text: {
      defaultProps: {
        c: AppColors.textPrimary,
      },
    },
    Title: {
      defaultProps: {
        c: AppColors.textDark,
      },
    },

    AppShell: {
      styles: {
        main: {
          backgroundColor: AppColors.background,
        },
      },
    },
  },
});
