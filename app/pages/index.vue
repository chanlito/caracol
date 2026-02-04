<template>
  <div class="container mx-auto flex min-h-full max-w-5xl flex-col items-center justify-center px-4 py-16">
    <h1 class="mb-2 text-3xl font-bold">
      Welcome to Caracol
    </h1>
    <p class="mb-8 text-center text-muted-foreground">
      Landing page. Go to the app or admin area using the links above or below.
    </p>
    <div class="flex gap-4">
      <Button as-child>
        <NuxtLink to="/app">Open app</NuxtLink>
      </Button>
      <Button
        variant="outline"
        as-child
      >
        <NuxtLink to="/admin">Admin</NuxtLink>
      </Button>
    </div>
  </div>
</template>
