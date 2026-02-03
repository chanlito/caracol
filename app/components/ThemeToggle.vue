<script setup lang="ts">
const colorMode = useColorMode()

// Preference is synced from cookie in middleware, so server and client match — no hydration mismatch.

const theme = computed(() => {
  switch (colorMode.preference) {
    case 'light':
      return { icon: 'lucide:sun', label: 'Light mode' }
    case 'dark':
      return { icon: 'lucide:moon', label: 'Dark mode' }
    case 'system':
      return { icon: 'lucide:monitor', label: 'System preference' }
    default:
      return { icon: 'lucide:monitor', label: 'Toggle theme' }
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
</script>

<template>
  <Tooltip>
    <TooltipTrigger as-child>
      <Button
        variant="ghost"
        size="icon"
        :aria-label="theme.label"
        @click="toggleTheme"
      >
        <Icon
          :name="theme.icon"
          class="h-5 w-5"
        />
      </Button>
    </TooltipTrigger>
    <TooltipContent>
      <p>{{ theme.label }}</p>
    </TooltipContent>
  </Tooltip>
</template>
