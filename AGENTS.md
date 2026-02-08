# Repository Guidelines

## Scope

This guide applies to the whole repository. Default to minimal, safe edits that preserve existing patterns.

## Hard Rules

- MUST keep changes small and focused.
- MUST use `npm` for package manager commands.
- MUST prefer `app/` for UI work and `public/` for static assets.
- MUST use TypeScript/ESM conventions already used in the repo.
- DO NOT add Prettier; formatting is handled by ESLint Stylistic.
- DO NOT modify `app/components/ui/` without explicit user permission.
- MUST set `useHead({ title: '...' })` for every new page in `app/pages/**`.
- If asked to commit:
  - nothing staged -> commit all current changes
  - some files staged -> commit staged files only

## Commands

| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Start Nuxt dev server at `http://localhost:7777` |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build |
| `npm run generate` | Generate static output |
| `npm run lint` | Run ESLint with `--fix` (this command can modify files) |

## UI and shadcn-vue Rules

- Use shadcn-vue as provided; keep base components upgradable.
- Components under `app/components/ui/` are auto-imported by Nuxt.
- Prefer `lucide-vue-next` icons first; use `@nuxt/icon` only if needed.
- For custom behavior, create wrappers in `app/components/`.

### Auto-imports (good vs bad)

```vue
<!-- Good: no explicit ui imports -->
<template>
  <Card>
    <CardHeader>
      <CardTitle>Hello</CardTitle>
    </CardHeader>
  </Card>
</template>
```

```vue
<!-- Bad: unnecessary explicit imports -->
<script setup lang="ts">
import { Card, CardHeader, CardTitle } from '~/components/ui/card'
</script>
```

### Wrapper Pattern (good vs bad)

```vue
<!-- Good: app/components/SubmitButton.vue -->
<script setup lang="ts">
import { Loader2 } from 'lucide-vue-next'

defineProps<{ loading?: boolean }>()
</script>

<template>
  <Button type="submit" :disabled="loading">
    <Loader2 v-if="loading" class="size-4 animate-spin" />
    <slot />
  </Button>
</template>
```

```vue
<!-- Bad: editing a shadcn default directly -->
<!-- app/components/ui/button/Button.vue -->
<script setup lang="ts">
defineProps<{ loading?: boolean }>()
</script>
```

### Event Handlers (good vs bad)

```vue
<!-- Good -->
<script setup lang="ts">
function handleClick() {
  // Handle click
}
</script>

<template>
  <Button @click="handleClick">Click me</Button>
</template>
```

```vue
<!-- Bad -->
<template>
  <Button @click="() => handleClick()">Click me</Button>
</template>
```

## Verification Policy

- Run verification after finishing edits, not mid-edit.
- Default verification: `npm run lint`.
- `npm run lint` uses `--fix`; review file changes after it runs.
- Run `npm run build` when changes affect config, routing, modules, dependencies, layouts, or cross-cutting app behavior.
- `npm run build` is optional for tiny local UI tweaks already validated in dev.
- If any check is skipped, report what was skipped and why.

## Execution Checklist

1. Inspect relevant files and current patterns.
2. Make minimal, targeted edits.
3. Run verification at the end of coding.
4. Report changed files, validation run, and any skipped checks.

## Commit Rules

- Use Conventional Commits with emojis: `type(scope): emoji message`.
- Common types:
  - `feat`: ✨
  - `fix`: 🐛
  - `docs`: 📝
  - `refactor`: ♻️
  - `test`: ✅
  - `chore`: 🔧

Examples:
- `feat(ui): ✨ add hero section`
- `fix(nav): 🐛 correct mobile menu toggle`
