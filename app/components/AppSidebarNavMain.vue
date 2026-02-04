<script setup lang="ts">
import { LayoutDashboard, Settings } from 'lucide-vue-next'

const route = useRoute()

function isActive(path: string) {
  if (path === '/app')
    return route.path === '/app'
  return route.path.startsWith(path)
}
</script>

<template>
  <SidebarGroup>
    <SidebarGroupLabel>Navigation</SidebarGroupLabel>
    <SidebarGroupContent>
      <SidebarMenu>
        <SidebarMenuItem>
          <SidebarMenuButton
            :is-active="isActive('/app')"
            tooltip="Dashboard"
            as-child
          >
            <NuxtLink to="/app">
              <LayoutDashboard class="size-4" />
              <span>Dashboard</span>
            </NuxtLink>
          </SidebarMenuButton>
        </SidebarMenuItem>
        <SidebarMenuItem>
          <SidebarMenuButton
            :is-active="isActive('/app/settings')"
            tooltip="Settings"
            as-child
          >
            <NuxtLink to="/app/settings">
              <Settings class="size-4" />
              <span>Settings</span>
            </NuxtLink>
          </SidebarMenuButton>
        </SidebarMenuItem>
      </SidebarMenu>
    </SidebarGroupContent>
  </SidebarGroup>
</template>
