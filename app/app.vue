<script setup lang="ts">
const appConfig = useAppConfig()
const route = useRoute()

useHead(() => ({
  titleTemplate: (titleChunk) => {
    const brandTitle = route.path.startsWith('/admin')
      ? `${appConfig.branding.name} (${appConfig.titles.adminSuffix})`
      : appConfig.branding.name

    return titleChunk
      ? `${titleChunk} · ${brandTitle}`
      : brandTitle
  },
}))
</script>

<template>
  <TooltipProvider>
    <div>
      <NuxtRouteAnnouncer />
      <NuxtLayout>
        <NuxtPage />
      </NuxtLayout>
    </div>
  </TooltipProvider>
</template>
