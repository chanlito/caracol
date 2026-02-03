<template>
  <div>
    <h1 class="mb-2 text-2xl font-semibold">
      App dashboard
    </h1>
    <p class="mb-6 text-muted-foreground">
      Welcome to the app. Use the sidebar to navigate.
    </p>
    <Card>
      <CardHeader>
        <CardTitle>Getting started</CardTitle>
        <CardDescription>Go to Settings or back to the main site.</CardDescription>
      </CardHeader>
      <CardFooter class="gap-2">
        <Button as-child>
          <NuxtLink to="/app/settings">Settings</NuxtLink>
        </Button>
        <Button
          variant="outline"
          as-child
        >
          <NuxtLink to="/">Home</NuxtLink>
        </Button>
      </CardFooter>
    </Card>
  </div>
</template>
