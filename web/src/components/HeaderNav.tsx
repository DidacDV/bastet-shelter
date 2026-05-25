import { Group, Box, UnstyledButton, Title, Select } from "@mantine/core";
import { Link, useLocation } from "react-router-dom";
import { AppColors } from "../theme/constants";
import logo from "../assets/images/logo.png";
import { useAuth } from "../context/authContext";
import { supportedLocales, useLocalization } from "../localization/localization";

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
  const { isLoggedIn, logout } = useAuth();
  const { locale, setLocale, t } = useLocalization();

  const NavItem = ({ to, label }: { to: string; label: string }) => {
    const isActive = location.pathname === to;
    return (
      <Link
        to={to}
        className={`
          relative text-sm font-medium tracking-wide no-underline pb-0.5
          transition-colors duration-200
          ${isActive ? "text-text-dark" : "text-text-secondary hover:text-text-dark"}
          after:content-[''] after:absolute after:-bottom-0.5 after:left-0 
          after:h-[1.5px] after:bg-primary after:transition-all after:duration-250
          ${isActive ? "after:w-full" : "after:w-0 hover:after:w-full"}
        `}
      >
        {label}
      </Link>
    );
  };

  return (
    <Box
      component="header"
      bg={AppColors.surface}
      px={32}
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
      }}
    >
      <UnstyledButton
        component={Link}
        to="/"
        style={{ display: "flex", alignItems: "center", gap: 10 }}
      >
        <img
          src={logo}
          alt={t("header.logoAlt")}
          style={{ height: 54, width: "auto", display: "block" }}
        />
        <Title
          order={3}
          style={{
            color: AppColors.textPrimary,
            fontWeight: 600,
            fontSize: "1rem",
            letterSpacing: "0.02em",
          }}
        >
          BastetShelter
        </Title>
      </UnstyledButton>

      <Group
        gap="xl"
        visibleFrom="sm"
        style={{
          position: "absolute",
          left: "50%",
          transform: "translateX(-50%)",
        }}
      >
        <NavItem to="/animals" label={t("header.findPet")} />
        {isLoggedIn && (
          <NavItem to="/adoptions" label={t("header.myAdoptions")} />
        )}
      </Group>

      <Group gap="sm">
        <Select
          aria-label={t("profile.language")}
          value={locale}
          data={supportedLocales.map((item) => ({
            value: item.code,
            label: t(item.labelKey),
          }))}
          onChange={(value) => {
            if (value === "en" || value === "ca" || value === "es") {
              setLocale(value);
            }
          }}
          allowDeselect={false}
          w={110}
        />

        {!isLoggedIn ? (
          <UnstyledButton
            component={Link}
            to="/login"
            className="
              flex items-center gap-1.5 text-[13px] font-medium tracking-wider
              text-primary bg-transparent border-[1.5px] border-primary rounded-sm
              px-[18px] py-[7px] transition-all duration-200
              hover:bg-primary hover:text-white
            "
          >
            {t("header.logIn")} <ArrowIcon />
          </UnstyledButton>
        ) : (
          <UnstyledButton
            onClick={logout}
            className="
              flex items-center gap-1.5 text-[13px] font-medium tracking-wider
              text-error bg-transparent border-[1.5px] border-error rounded-sm
              px-[18px] py-[7px] transition-all duration-200
              hover:bg-error hover:text-white
            "
          >
            {t("header.logOut")}
          </UnstyledButton>
        )}
      </Group>
    </Box>
  );
}
