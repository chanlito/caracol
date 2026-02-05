<template>
  <SidebarProvider>
    <AppSidebar>
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
