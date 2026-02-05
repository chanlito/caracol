# Repository Guidelines

## Agent-Specific Notes

- Keep changes small and focused.
- Prefer updating `app/` for UI changes and `public/` for static assets.
- Use `npm` for all package manager commands.
- If asked to commit and nothing is staged, assume all current changes should be committed; if some changes are staged, only commit the staged set.
- **Do not modify files in `app/components/ui/`** without explicit user permission — these are shadcn-vue defaults. Extend them instead (see [Extending UI Components](#extending-ui-components)).

## Project Structure

| Path | Description |
|------|-------------|
| `app/` | Nuxt app source (`app/app.vue` is the root component) |
| `app/components/ui/` | shadcn-vue UI components (auto-imported) |
| `app/pages/` | File-based routing pages |
| `public/` | Static assets served as-is (e.g., `favicon.ico`, `robots.txt`) |
| `nuxt.config.ts` | Nuxt configuration |
| `eslint.config.mjs` | Linting configuration |
| `package.json` | Scripts and dependencies |

## Commands

| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Run dev server at `http://localhost:3000` |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build locally |
| `npm run generate` | Generate static site output |

## UI Components

This project uses **shadcn-vue**. To add a new component:

```bash
npx shadcn-vue@latest add <component>
```

### Themes

To install a new shadcn theme:

```bash
npx shadcn-vue@latest add <theme-url>
```

### Auto-imports

Components in `app/components/ui/` are auto-imported by Nuxt. Do **not** explicitly import them.

**Good** (no imports needed):

```vue
<template>
  <Card>
    <CardHeader>
      <CardTitle>Hello</CardTitle>
    </CardHeader>
    <CardFooter>
      <Button>Click me</Button>
    </CardFooter>
  </Card>
</template>
```

**Bad** (unnecessary explicit imports):

```vue
<template>
  <Card>
    <CardHeader>
      <CardTitle>Hello</CardTitle>
    </CardHeader>
    <CardFooter>
      <Button>Click me</Button>
    </CardFooter>
  </Card>
</template>

<script setup lang="ts">
import { Card, CardFooter, CardHeader, CardTitle } from '~/components/ui/card'
import { Button } from '~/components/ui/button'
</script>
```

### Icons

This project uses **lucide-vue-next** as the primary icon library (consistent with shadcn-vue).

**Primary: lucide-vue-next**

```vue
<script setup lang="ts">
import { Sun, Moon, ChevronRight } from 'lucide-vue-next'
</script>

<template>
  <Sun class="size-4" />
  <Moon :size="20" />
  <ChevronRight class="ml-auto" />
</template>
```

Browse Lucide icons at [lucide.dev/icons](https://lucide.dev/icons).

**Secondary: @nuxt/icon** (for icons not available in Lucide)

Use `@nuxt/icon` only when Lucide doesn't have the icon you need. The `Icon` component is auto-imported.

```vue
<template>
  <Icon name="tabler:brand-github" class="size-4" />
  <Icon name="simple-icons:nuxtdotjs" />
</template>
```

Install additional icon collections: `npm i -D @iconify-json/tabler @iconify-json/simple-icons`

Browse all icons at [icones.js.org](https://icones.js.org).

### Extending UI Components

Files in `app/components/ui/` are shadcn-vue defaults. To customize behavior, **create wrapper components** in `app/components/` instead of modifying the originals.

**Good** (extend with a wrapper component in `app/components/`):

```vue
<!-- app/components/SubmitButton.vue -->
<script setup lang="ts">
import { Loader2 } from 'lucide-vue-next'

defineProps<{
  loading?: boolean
}>()
</script>

<template>
  <Button type="submit" :disabled="loading">
    <Loader2 v-if="loading" class="size-4 animate-spin" />
    <slot />
  </Button>
</template>
```

**Bad** (modifying shadcn-vue defaults directly):

```vue
<!-- app/components/ui/button/Button.vue — DON'T DO THIS -->
<script setup lang="ts">
// Adding custom props/logic to the shadcn-vue default...
import { Loader2 } from 'lucide-vue-next'

defineProps<{
  loading?: boolean  // ❌ Don't add custom props here
}>()
</script>
```

This keeps shadcn-vue components upgradable and your customizations isolated.

## Coding Style

- **Language**: TypeScript/ESM (`"type": "module"` in `package.json`)
- **Linting**: ESLint via `eslint.config.mjs`
- **Formatting**: ESLint (Stylistic) only — do not use Prettier
- **Naming**:
  - `PascalCase` for component file names and tags
  - `kebab-case` for in-DOM templates and route file names
- **Event Handlers**: Prefer function declarations for event handlers like button clicks.

**Good**:

```vue
<template>
  <Button @click="handleClick">Click me</Button>
</template>

<script setup lang="ts">
function handleClick() {
  // Handle click
}
</script>
```

**Bad**:

```vue
<template>
  <Button @click="() => handleClick()">Click me</Button>
</template>
```

## Commit Guidelines

Conventional Commits with emojis: `type(scope): emoji message`

| Type | Emoji | Description |
|------|-------|-------------|
| `feat` | ✨ | New feature |
| `fix` | 🐛 | Bug fix |
| `docs` | 📝 | Documentation |
| `style` | 🎨 | Code style/formatting |
| `refactor` | ♻️ | Code refactoring |
| `perf` | ⚡ | Performance |
| `test` | ✅ | Tests |
| `build` | 🏗️ | Build system |
| `ci` | 🤖 | CI/CD |
| `chore` | 🔧 | Maintenance |
| `revert` | ⏪ | Revert changes |

Examples:
- `feat(ui): ✨ add hero section`
- `fix(nav): 🐛 correct mobile menu toggle`

## Pull Request Guidelines

- Short summary describing changes
- UI screenshots when relevant
- Link related issues/context

## Testing

No test framework configured yet. If adding tests, document the framework and add scripts in `package.json`.
