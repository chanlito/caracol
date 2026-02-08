<script setup lang="ts">
useHead({
  title: 'Dashboard',
})
</script>

<template>
  <div>
    <h1 class="mb-2 text-2xl font-semibold">
      App dashboard
    </h1>
    <p class="mb-6 text-muted-foreground">
      Welcome to the app. Use the sidebar to navigate. Scroll down to see the sticky header stay in place.
    </p>
    <Card class="mb-8">
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

    <div class="space-y-6">
      <h2 class="text-lg font-medium">
        Long content for scroll testing
      </h2>
      <p class="text-muted-foreground">
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
      </p>
      <p class="text-muted-foreground">
        Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Curabitur pretium tincidunt lacus. Nulla facilisi. Morbi tempus iaculis urna id volutpat. Phasellus laoreet lorem vel dolor tempus vehicula. Aenean a velit massa ut lacinia.
      </p>
      <p class="text-muted-foreground">
        Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est mauris placerat eleifend leo.
      </p>
      <p class="text-muted-foreground">
        Integer quis nulla at metus lobortis egestas. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Etiam accumsan ullamcorper velit. Nam pulvinar lectus quis magna. Sed convallis magna eu sem. Praesent aliquam, enim at fermentum mollis, ligula massa pharetra magna, ac aliquet massa diam eget dui.
      </p>
      <p class="text-muted-foreground">
        Fusce vel dui. Sed augue lorem, gravida auctor, ultricies id, condimentum ut, nibh. Duis lobortis massa imperdiet quam. Suspendisse potenti. Pellentesque commodo eros a enim. Vestibulum turpis sem, aliquet eget, lobortis pellentesque, rutrum eu, nisl. Nullam libero nunc, consectetuer sit amet, cursus vel, facilisis at, eros.
      </p>
      <p class="text-muted-foreground">
        Maecenas fermentum consequat mi. Donec fermentum. Pellentesque malesuada nulla a mi. Duis sapien sem, aliquet nec, commodo eget, consequat quis, libero. Nam lectus nulla, cursus non, cursus eget, tempor in, purus. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis.
      </p>
      <p class="text-muted-foreground">
        Morbi interdum mollis sapien. Sed ac risus. Phasellus lacinia, magna a ullamcorper laoreet, lectus arcu pulvinar risus, vitae facilisis libero dolor a purus. Sed vel lacus. Mauris nibh felis, adipiscing varius, adipiscing in, lacinia vel, tellus. Suspendisse ac urna. Etiam pellentesque mauris ut lectus.
      </p>
      <p class="text-muted-foreground">
        Nunc dignissim risus id metus. Cras ornare tristique elit. Vivamus vestibulum nulla nec ante. Praesent placerat risus quis eros. Fusce pellentesque suscipit nibh. Integer euismod ante ut lacus. Vestibulum sed magna at nunc commodo placerat. Praesent blandit laoreet nibh.
      </p>
      <p class="text-muted-foreground">
        Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero.
      </p>
      <p class="text-muted-foreground">
        Ut tincidunt tincidunt erat. Etiam feugiat lorem non metus. Vestibulum dapibus nunc ac augue. Curabitur vestibulum aliquam leo. Praesent egestas neque eu enim. In hac habitasse platea dictumst. Fusce a quam. Etiam ut purus mattis mauris sodales aliquam. Curabitur nisi. Quisque malesuada placerat nisl.
      </p>
      <p class="text-muted-foreground">
        Nam ipsum risus, rutrum vitae, vestibulum eu, molestie vel, lacus. Sed augue ipsum, egestas nec, vestibulum et, malesuada adipiscing, dui. Vestibulum facilisis, purus nec pulvinar ultricies, ligula pede cursus tortor, vitae mattis tortor lacus sit amet elit. Aenean imperdiet. Donec posuere vulputate arcu.
      </p>
      <p class="text-muted-foreground">
        Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc.
      </p>
      <p class="text-muted-foreground">
        Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc.
      </p>
    </div>
  </div>
</template>
