export type ThemePreference = 'light' | 'dark' | 'system'

export function useTheme() {
  const colorMode = useColorMode()

  const theme = computed(() => {
    switch (colorMode.preference) {
      case 'light':
        return { preference: 'light' as ThemePreference, label: 'Light mode', icon: 'lucide:sun' as const }
      case 'dark':
        return { preference: 'dark' as ThemePreference, label: 'Dark mode', icon: 'lucide:moon' as const }
      case 'system':
        return { preference: 'system' as ThemePreference, label: 'System preference', icon: 'lucide:monitor' as const }
      default:
        return { preference: 'system' as ThemePreference, label: 'Toggle theme', icon: 'lucide:monitor' as const }
    }
  })

  function toggleTheme() {
    if (colorMode.preference === 'light') {
      colorMode.preference = 'dark'
    }
    else if (colorMode.preference === 'dark') {
      colorMode.preference = 'system'
    }
    else {
      colorMode.preference = 'light'
    }
  }

  return { theme, toggleTheme }
}
