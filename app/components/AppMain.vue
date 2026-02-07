<script setup lang="ts">
defineOptions({
  inheritAttrs: false,
})
</script>

<template>
  <SidebarInset
    class="min-h-0 overflow-y-auto overscroll-y-contain"
    v-bind="$attrs"
  >
    <div class="flex flex-1 flex-col p-6">
      <header class="sticky top-0 z-10 -mx-6 -mt-6 flex items-center bg-background px-6 py-4 mb-4 md:rounded-t-xl">
        <SidebarTrigger />
      </header>
      <slot />
    </div>
  </SidebarInset>
</template>
