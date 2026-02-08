<script setup lang="ts">
useHead({
  title: 'Settings',
})
</script>

<template>
  <div>
    <h1 class="mb-2 text-2xl font-semibold">
      Settings
    </h1>
    <p class="mb-6 text-muted-foreground">
      Manage your app preferences here.
    </p>
    <Card>
      <CardHeader>
        <CardTitle>App settings</CardTitle>
        <CardDescription>Placeholder for settings options.</CardDescription>
      </CardHeader>
      <CardFooter>
        <Button as-child>
          <NuxtLink to="/app">Back to dashboard</NuxtLink>
        </Button>
      </CardFooter>
    </Card>
  </div>
</template>
