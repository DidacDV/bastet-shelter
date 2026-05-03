import { Group, Box, UnstyledButton, Title } from "@mantine/core";
import { Link, useLocation } from "react-router-dom";
import { AppColors } from "../theme/constants";
import logo from "../../public/logo.png";
import { useAuth } from "../context/authContext";

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
      className="flex items-center justify-between px-8 h-16"
    >
      <UnstyledButton
        component={Link}
        to="/"
        className="flex items-center gap-2.5"
      >
        <img
          src={logo}
          alt="BastetShelter logo"
          className="h-[54px] w-auto block"
        />
        <Title
          order={3}
          className="no-underline text-text-primary tracking-wide text-base"
        >
          BastetShelter
        </Title>
      </UnstyledButton>

      <Group gap="xl" visibleFrom="sm">
        <NavItem to="/animals" label="Find a Pet" />
        
        {isLoggedIn && <NavItem to="/adoption" label="My Adoptions" />}
      </Group>

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
          Log In <ArrowIcon />
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
          Log Out
        </UnstyledButton>
      )}
    </Box>
  );
}