import { AppShell } from "@mantine/core";
import HeaderNav from "./HeaderNav";

interface LayoutProps {
  children: React.ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  return (
    <AppShell header={{ height: 70 }} padding="md" className="bg-[#F4F5FF]">
      <AppShell.Header>
        <HeaderNav />
      </AppShell.Header>

      <AppShell.Main>{children}</AppShell.Main>
    </AppShell>
  );
}
