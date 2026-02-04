<script setup lang="ts">
import type { SidebarProps } from '~/components/ui/sidebar'
import { LayoutDashboard } from 'lucide-vue-next'

defineOptions({ inheritAttrs: false })

const props = withDefaults(
  defineProps<SidebarProps>(),
  { side: 'left', variant: 'inset', collapsible: 'icon' },
)
</script>

<template>
  <Sidebar v-bind="{ ...props, ...$attrs }">
    <SidebarHeader>
      <div class="flex w-full items-center gap-2">
        <NuxtLink
          to="/app"
          class="flex min-w-0 flex-1 items-center gap-2 font-semibold group-data-[collapsible=icon]:flex-none group-data-[collapsible=icon]:justify-center"
        >
          <span class="flex size-8 shrink-0 items-center justify-center rounded-md bg-sidebar-accent group-data-[collapsible=icon]:size-8">
            <LayoutDashboard class="size-4" />
          </span>
          <span class="truncate group-data-[collapsible=icon]:hidden">App</span>
        </NuxtLink>
        <SidebarTrigger class="shrink-0" />
      </div>
    </SidebarHeader>
    <SidebarContent>
      <slot />
    </SidebarContent>
    <SidebarFooter>
      <slot name="footer" />
    </SidebarFooter>
  </Sidebar>
</template>
