<script setup lang="ts">
const { theme, toggleTheme } = useTheme()
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
