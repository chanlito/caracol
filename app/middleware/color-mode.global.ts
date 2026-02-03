export default defineNuxtRouteMiddleware(() => {
  if (!import.meta.server) return
  const cookie = useRequestHeaders(['cookie']).cookie as string | undefined
  const value = cookie?.match(/nuxt-color-mode=([^;]+)/)?.[1]?.trim()
  if (value === 'light' || value === 'dark' || value === 'system') {
    useColorMode().preference = value
  }
})
