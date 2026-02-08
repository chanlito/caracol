<script setup lang="ts">
import {
  AppWindow,
  ArrowRight,
  Code2,
  Database,
  Hammer,
  Server,
  ShieldCheck,
  Workflow,
} from 'lucide-vue-next'

const appConfig = useAppConfig()
const seoTitle = computed(() => `${appConfig.titles.home} · ${appConfig.branding.name}`)
const seoDescription = computed(
  () => `${appConfig.branding.name} helps teams build project tooling with clean UI patterns and practical guardrails.`,
)

useHead({
  title: seoTitle,
  meta: [
    {
      name: 'description',
      content: seoDescription,
    },
    {
      property: 'og:title',
      content: seoTitle,
    },
    {
      property: 'og:description',
      content: seoDescription,
    },
    {
      name: 'twitter:title',
      content: seoTitle,
    },
    {
      name: 'twitter:description',
      content: seoDescription,
    },
  ],
})

const capabilities = [
  {
    icon: Hammer,
    title: 'Tool Workspace',
    description: 'Build and organize project tools from one app surface.',
  },
  {
    icon: Workflow,
    title: 'Automation Flows',
    description: 'Define repeatable workflows for checks, releases, and operations.',
  },
  {
    icon: ShieldCheck,
    title: 'Operational Guardrails',
    description: 'Keep changes safe with clear boundaries and predictable rollout paths.',
  },
]

const stack = [
  {
    icon: AppWindow,
    title: 'Frontend',
    items: ['Nuxt 4', 'Vue 3', 'Tailwind CSS 4', 'shadcn-vue'],
  },
  {
    icon: Server,
    title: 'Runtime',
    items: ['TypeScript (ESM)', 'Composable app structure', 'Nuxt route/layout system'],
  },
  {
    icon: Database,
    title: 'Project Focus',
    items: ['Internal tooling UX', 'Reliable workflows', 'Developer velocity'],
  },
]
</script>

<template>
  <main class="mx-auto w-full max-w-5xl px-4 py-10 sm:px-6 sm:py-14">
    <section
      id="overview"
      class="scroll-mt-20 rounded-2xl border bg-card/80 p-6 shadow-sm sm:p-8"
    >
      <Badge
        variant="secondary"
        class="mb-4 rounded-full px-3 py-1 text-xs uppercase tracking-[0.12em]"
      >
        {{ appConfig.branding.name }} Project
      </Badge>
      <h1 class="text-3xl font-semibold leading-tight sm:text-4xl">
        One project space for tools, workflows, and operations.
      </h1>
      <p class="mt-4 max-w-3xl text-muted-foreground">
        {{ appConfig.branding.name }} is focused on helping teams build project tooling with a clean UI, typed patterns, and practical
        guardrails. This repo contains the app shell, admin surface, and shared UI foundations.
      </p>
      <div class="mt-6 flex flex-wrap gap-3">
        <Button as-child>
          <NuxtLink to="/app">
            Open app
            <ArrowRight class="size-4" />
          </NuxtLink>
        </Button>
        <Button
          variant="outline"
          as-child
        >
          <NuxtLink to="/admin">Open admin</NuxtLink>
        </Button>
      </div>
    </section>

    <section
      id="capabilities"
      class="mt-10 scroll-mt-20"
    >
      <h2 class="text-2xl font-semibold">
        Core Capabilities
      </h2>
      <p class="mt-2 text-muted-foreground">
        What this project is built to support right now.
      </p>
      <div class="mt-4 grid gap-4 md:grid-cols-3">
        <Card
          v-for="item in capabilities"
          :key="item.title"
          class="border-border/70"
        >
          <CardHeader>
            <div class="mb-2 inline-flex size-10 items-center justify-center rounded-lg border bg-muted/40 text-primary">
              <component
                :is="item.icon"
                class="size-5"
              />
            </div>
            <CardTitle>{{ item.title }}</CardTitle>
            <CardDescription>{{ item.description }}</CardDescription>
          </CardHeader>
        </Card>
      </div>
    </section>

    <section
      id="stack"
      class="mt-10 scroll-mt-20"
    >
      <h2 class="text-2xl font-semibold">
        Stack Overview
      </h2>
      <div class="mt-4 grid gap-4 md:grid-cols-3">
        <Card
          v-for="item in stack"
          :key="item.title"
          class="border-border/70"
        >
          <CardHeader>
            <CardTitle class="flex items-center gap-2 text-lg">
              <component
                :is="item.icon"
                class="size-4 text-primary"
              />
              {{ item.title }}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ul class="space-y-2 text-sm text-muted-foreground">
              <li
                v-for="point in item.items"
                :key="point"
                class="flex items-start gap-2"
              >
                <Code2 class="mt-0.5 size-3.5 shrink-0 text-primary" />
                <span>{{ point }}</span>
              </li>
            </ul>
          </CardContent>
        </Card>
      </div>
    </section>
  </main>
</template>
