<template>
  <div>
    <h1 class="mb-2 text-2xl font-semibold">
      Admin dashboard
    </h1>
    <p class="mb-6 text-muted-foreground">
      Admin area. Use the sidebar to manage content.
    </p>
    <Card>
      <CardHeader>
        <CardTitle>Overview</CardTitle>
        <CardDescription>Quick links to admin sections.</CardDescription>
      </CardHeader>
      <CardFooter class="gap-2">
        <Button as-child>
          <NuxtLink to="/admin/users">Users</NuxtLink>
        </Button>
        <Button
          variant="outline"
          as-child
        >
          <NuxtLink to="/">Back to site</NuxtLink>
        </Button>
      </CardFooter>
    </Card>
  </div>
</template>
