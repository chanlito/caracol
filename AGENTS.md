# Repository Guidelines

## Agent-Specific Notes

- Keep changes small and focused.
- Prefer updating `app/` for UI changes and `public/` for static assets.
- Use `npm` for all package manager commands.
- If asked to commit and nothing is staged, assume all current changes should be committed; if some changes are staged, only commit the staged set.

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

## Coding Style

- **Language**: TypeScript/ESM (`"type": "module"` in `package.json`)
- **Linting**: ESLint via `eslint.config.mjs`
- **Formatting**: ESLint (Stylistic) only — do not use Prettier
- **Naming**:
  - `PascalCase` for component file names and tags
  - `kebab-case` for in-DOM templates and route file names

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
