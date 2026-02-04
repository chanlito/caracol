<script setup lang="ts">
defineOptions({
  inheritAttrs: false,
})
</script>

<template>
  <SidebarInset v-bind="$attrs">
    <div class="flex flex-1 flex-col p-6">
      <slot />
    </div>
  </SidebarInset>
</template>
