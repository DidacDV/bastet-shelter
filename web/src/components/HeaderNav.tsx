import { Group, Text, Box, UnstyledButton, Title } from "@mantine/core";
import { Link, useLocation } from "react-router-dom";
import { AppColors } from "../theme/constants";
import logo from "../../public/logo.png";

const ArrowIcon = () => (
  <svg width="13" height="13" viewBox="0 0 13 13" fill="none">
    <path
      d="M2 6.5h9M7.5 3l3.5 3.5L7.5 10"
      stroke="currentColor"
      strokeWidth="1.4"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);

export default function HeaderNav() {
  const location = useLocation();

  const NavItem = ({ to, label }: { to: string; label: string }) => {
    const isActive = location.pathname === to;
    return (
      <Text
        component={Link}
        to={to}
        size="sm"
        fw={500}
        style={{
          textDecoration: "none",
          color: isActive ? AppColors.textDark : AppColors.textSecondary,
          position: "relative",
          paddingBottom: 2,
          letterSpacing: "0.01em",
          "&::after": {
            content: '""',
            position: "absolute",
            bottom: -2,
            left: 0,
            width: isActive ? "100%" : "0%",
            height: 1.5,
            background: AppColors.primary,
            transition: "width 0.25s cubic-bezier(.4,0,.2,1)",
          },
          "&:hover": { color: AppColors.textDark },
          "&:hover::after": { width: "100%" },
        }}
      >
        {label}
      </Text>
    );
  };

  return (
    <Box
      component="header"
      bg={AppColors.surface}
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "0 2rem",
        height: 64,
      }}
    >
      <UnstyledButton
        component={Link}
        to="/"
        style={{ display: "flex", alignItems: "center", gap: 10 }}
      >
        <img
          src={logo}
          alt="BastetShelter logo"
          style={{ height: 54, width: "auto", display: "block" }}
        />
        <Title
          style={{
            textDecoration: "none",
            color: AppColors.textPrimary,
            letterSpacing: "0.01em",
            fontSize: "1rem",
          }}
        >
          BastetShelter
        </Title>
      </UnstyledButton>

      <Group gap="xl" visibleFrom="sm">
        <NavItem to="/" label="Provinces" />
        <NavItem to="/animals" label="Find a Pet" />
        <NavItem to="/adoption" label="My Adoptions" />
      </Group>

      <UnstyledButton
        component={Link}
        to="/login"
        style={{
          display: "flex",
          alignItems: "center",
          gap: 6,
          fontSize: 13,
          fontWeight: 500,
          letterSpacing: "0.04em",
          color: AppColors.primary,
          background: "transparent",
          border: `1.5px solid ${AppColors.primary}`,
          borderRadius: 2,
          padding: "7px 18px",
          transition: "background 0.18s, color 0.18s",
          "&:hover": {
            background: AppColors.primary,
            color: "#fff",
          },
        }}
      >
        Log In <ArrowIcon />
      </UnstyledButton>
    </Box>
  );
}
