<template>
  <div class="flex min-h-screen flex-col">
    <header class="border-b">
      <div class="flex h-14 items-center justify-between px-4">
        <NuxtLink
          to="/app"
          class="font-semibold"
        >
          App
        </NuxtLink>
        <div class="flex items-center gap-2">
          <ThemeToggle />
          <Button
            variant="outline"
            size="sm"
            as-child
          >
            <NuxtLink to="/">Leave app</NuxtLink>
          </Button>
        </div>
      </div>
    </header>
    <div class="flex flex-1">
      <aside class="w-48 border-r p-4">
        <nav class="flex flex-col gap-1">
          <Button
            variant="ghost"
            size="sm"
            class="justify-start"
            as-child
          >
            <NuxtLink to="/app">Dashboard</NuxtLink>
          </Button>
          <Button
            variant="ghost"
            size="sm"
            class="justify-start"
            as-child
          >
            <NuxtLink to="/app/settings">Settings</NuxtLink>
          </Button>
        </nav>
      </aside>
      <main class="flex-1 p-6">
        <slot />
      </main>
    </div>
  </div>
</template>
