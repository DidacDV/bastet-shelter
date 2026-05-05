import { AppShell } from "@mantine/core";
import HeaderNav from "./HeaderNav";

interface LayoutProps {
  children: React.ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  return (
    <AppShell header={{ height: 48 }} className="bg-background">
      <AppShell.Header>
        <HeaderNav />
      </AppShell.Header>

      <AppShell.Main>{children}</AppShell.Main>
    </AppShell>
  );
}
