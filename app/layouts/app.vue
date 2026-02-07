<script setup lang="ts">
useHead({
  htmlAttrs: { class: 'app-shell-lock' },
  bodyAttrs: { class: 'app-shell-lock' },
})
</script>

<template>
  <SidebarProvider class="relative h-svh overflow-hidden">
    <AppSidebar class="md:!absolute">
      <AppSidebarNavMain />
      <template #footer>
        <AppSidebarUser />
      </template>
    </AppSidebar>
    <AppMain>
      <slot />
    </AppMain>
  </SidebarProvider>
</template>
