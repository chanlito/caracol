<script setup lang="ts">
import type { SidebarProps } from '~/components/ui/sidebar'
import { Building2 } from 'lucide-vue-next'

defineOptions({ inheritAttrs: false })

const props = withDefaults(
  defineProps<SidebarProps>(),
  { side: 'left', variant: 'inset', collapsible: 'icon' },
)
</script>

<template>
  <Sidebar v-bind="{ ...props, ...$attrs }">
    <SidebarHeader>
      <NuxtLink
        to="/app"
        class="flex min-w-0 w-full items-center gap-2 font-semibold group-data-[collapsible=icon]:flex-none group-data-[collapsible=icon]:justify-center"
      >
        <span class="flex size-8 shrink-0 items-center justify-center rounded-md bg-sidebar-accent group-data-[collapsible=icon]:size-8">
          <Building2 class="size-4" />
        </span>
        <span class="flex min-w-0 flex-1 flex-col gap-0.5 group-data-[collapsible=icon]:hidden">
          <span class="truncate font-medium">Acme Inc</span>
          <span class="truncate text-xs font-normal text-muted-background">Dashboard</span>
        </span>
      </NuxtLink>
    </SidebarHeader>
    <SidebarContent>
      <slot />
    </SidebarContent>
    <SidebarFooter>
      <slot name="footer" />
    </SidebarFooter>
  </Sidebar>
</template>
