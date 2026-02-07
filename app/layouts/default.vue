<script setup lang="ts">
const route = useRoute()
const isHome = computed(() => route.path === '/')
</script>

<template>
  <div class="flex min-h-screen flex-col">
    <header class="sticky top-0 z-40 border-b bg-background/90 backdrop-blur supports-[backdrop-filter]:bg-background/70">
      <div class="container mx-auto flex h-14 max-w-5xl items-center justify-between gap-3 px-4">
        <NuxtLink
          to="/"
          class="font-semibold"
        >
          Caracol
        </NuxtLink>
        <nav class="flex items-center gap-1 sm:gap-2">
          <template v-if="isHome">
            <Button
              class="hidden sm:inline-flex"
              variant="ghost"
              size="sm"
              as-child
            >
              <NuxtLink to="/#overview">Overview</NuxtLink>
            </Button>
            <Button
              class="hidden sm:inline-flex"
              variant="ghost"
              size="sm"
              as-child
            >
              <NuxtLink to="/#capabilities">Capabilities</NuxtLink>
            </Button>
            <Button
              class="hidden sm:inline-flex"
              variant="ghost"
              size="sm"
              as-child
            >
              <NuxtLink to="/#stack">Stack</NuxtLink>
            </Button>
          </template>
          <Button
            variant="ghost"
            size="sm"
            as-child
          >
            <NuxtLink to="/app">App</NuxtLink>
          </Button>
          <Button
            variant="outline"
            size="sm"
            as-child
          >
            <NuxtLink to="/admin">Admin</NuxtLink>
          </Button>
          <ThemeToggle />
        </nav>
      </div>
    </header>
    <main class="flex flex-1 flex-col">
      <slot />
    </main>
  </div>
</template>
