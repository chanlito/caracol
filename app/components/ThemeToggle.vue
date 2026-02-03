<script setup lang="ts">
const colorMode = useColorMode()

const iconName = computed(() => {
  switch (colorMode.preference) {
    case 'light':
      return 'lucide:sun'
    case 'dark':
      return 'lucide:moon'
    case 'system':
      return 'lucide:monitor'
    default:
      return 'lucide:monitor'
  }
})

const label = computed(() => {
  switch (colorMode.preference) {
    case 'light':
      return 'Light mode'
    case 'dark':
      return 'Dark mode'
    case 'system':
      return 'System preference'
    default:
      return 'Toggle theme'
  }
})

const toggleTheme = () => {
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
  <Button
    variant="ghost"
    size="icon"
    :aria-label="label"
    @click="toggleTheme"
  >
    <Icon
      :name="iconName"
      class="h-5 w-5"
    />
  </Button>
</template>
