import { AppShell } from '@mantine/core'

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <AppShell padding="md">
      <AppShell.Main>{children}</AppShell.Main>
    </AppShell>
  )
}