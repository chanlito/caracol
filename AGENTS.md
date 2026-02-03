# Repository Guidelines

## Project Structure & Module Organization
- `app/`: Nuxt app source. `app/app.vue` is the root component.
- `public/`: Static assets served as-is (e.g., `public/favicon.ico`, `public/robots.txt`).
- `nuxt.config.ts`: Nuxt configuration.
- `eslint.config.mjs`: Linting configuration.
- `package.json`: Scripts and dependencies.

## Build, Test, and Development Commands
- `pnpm install`: Install dependencies (use `pnpm` for this repo).
- `pnpm dev`: Run the Nuxt dev server at `http://localhost:3000`.
- `pnpm build`: Build for production.
- `pnpm preview`: Preview the production build locally.
- `pnpm generate`: Generate a static site output (Nuxt generate).

## Coding Style & Naming Conventions
- Language: TypeScript/ESM (`"type": "module"` in `package.json`).
- Linting: ESLint via `eslint.config.mjs`. Run ESLint in your editor or CI when added.
- Formatting: ESLint (Stylistic) is the only formatter; do not use Prettier or other formatters. Use ESLint auto-fix for formatting to keep style rules centralized and consistent.
- Naming: Follow Vue component casing best practices: prefer `PascalCase` for component file names and component tags; use `kebab-case` only for in-DOM templates (HTML is case-insensitive). For Nuxt route file names, `kebab-case` is recommended for URL readability when adding new routes.

## Testing Guidelines
- No test framework is configured yet.
- If adding tests, document the chosen framework and add scripts (e.g., `pnpm test`) in `package.json`.

## Commit Guidelines
Conventional Commits with emojis: `type(scope): emoji message` where type+emoji are `feat`✨, `fix`🐛, `docs`📝, `style`🎨, `refactor`♻️, `perf`⚡, `test`✅, `build`🏗️, `ci`🤖, `chore`🔧, `revert`⏪.  
Examples:
- `feat(ui): ✨ add hero section`
- `fix(nav): 🐛 correct mobile menu toggle`

## Pull Request Guidelines
PRs: short summary, UI screenshots when relevant, linked issues/context.

## Agent-Specific Notes
- Keep changes small and focused.
- Prefer updating `app/` for UI changes and `public/` for static assets.
- If asked to commit and nothing is staged, assume all current changes should be committed; if some changes are staged, only commit the staged set.
- Use `pnpm` for all package manager commands.
