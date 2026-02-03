<template>
  <div class="flex min-h-screen flex-col bg-muted/30">
    <header class="border-b bg-background">
      <div class="flex h-14 items-center justify-between px-4">
        <NuxtLink
          to="/admin"
          class="font-semibold"
        >
          Admin
        </NuxtLink>
        <div class="flex items-center gap-2">
          <ThemeToggle />
          <Button
            variant="outline"
            size="sm"
            as-child
          >
            <NuxtLink to="/">Back to site</NuxtLink>
          </Button>
        </div>
      </div>
    </header>
    <div class="flex flex-1">
      <aside class="w-52 border-r bg-background p-4">
        <nav class="flex flex-col gap-1">
          <Button
            variant="ghost"
            size="sm"
            class="justify-start"
            as-child
          >
            <NuxtLink to="/admin">Dashboard</NuxtLink>
          </Button>
          <Button
            variant="ghost"
            size="sm"
            class="justify-start"
            as-child
          >
            <NuxtLink to="/admin/users">Users</NuxtLink>
          </Button>
        </nav>
      </aside>
      <main class="flex-1 p-6">
        <slot />
      </main>
    </div>
  </div>
</template>
