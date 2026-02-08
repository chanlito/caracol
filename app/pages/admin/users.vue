<script setup lang="ts">
useHead({
  title: 'Users',
})
</script>

<template>
  <div>
    <h1 class="mb-2 text-2xl font-semibold">
      Users
    </h1>
    <p class="mb-6 text-muted-foreground">
      Manage user accounts. This is a placeholder page.
    </p>
    <Card>
      <CardHeader>
        <CardTitle>User list</CardTitle>
        <CardDescription>User management will go here.</CardDescription>
      </CardHeader>
      <CardFooter>
        <Button as-child>
          <NuxtLink to="/admin">Back to dashboard</NuxtLink>
        </Button>
      </CardFooter>
    </Card>
  </div>
</template>
