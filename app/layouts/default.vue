<template>
  <div class="flex min-h-screen flex-col">
    <header class="border-b">
      <div class="container mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
        <NuxtLink
          to="/"
          class="font-semibold"
        >
          Caracol
        </NuxtLink>
        <nav class="flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            as-child
          >
            <NuxtLink to="/">Home</NuxtLink>
          </Button>
          <Button
            variant="ghost"
            size="sm"
            as-child
          >
            <NuxtLink to="/app">App</NuxtLink>
          </Button>
          <Button
            variant="ghost"
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
