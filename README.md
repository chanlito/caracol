# Caracol

A modern Nuxt 4 application built with shadcn-vue, Tailwind CSS, and TypeScript.

## Quick Start

Install dependencies:

```bash
npm install
```

Start the development server:

```bash
npm run dev
```

Visit `http://localhost:3000` to see your app.

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally
- `npm run generate` - Generate static site
- `npm run lint` - Lint and fix code

## Tech Stack

- **Nuxt 4** - Vue.js framework
- **shadcn-vue** - UI component library
- **Tailwind CSS** - Utility-first CSS framework
- **TypeScript** - Type-safe JavaScript
- **@nuxt/icon** - Icon system with Iconify
- **@nuxtjs/color-mode** - Dark/light theme support

## Project Structure

```
app/
├── components/     # Vue components (auto-imported)
│   └── ui/        # shadcn-vue components
├── pages/         # File-based routing
├── assets/        # CSS and other assets
└── lib/           # Utilities
```

## Adding UI Components

This project uses [shadcn-vue](https://www.shadcn-vue.com/). To add a component:

```bash
npx shadcn-vue@latest add <component-name>
```

Components are auto-imported - no need to manually import them.

## Icons

Icons are provided via [@nuxt/icon](https://nuxt.com/modules/icon). Browse available icons at [icones.js.org](https://icones.js.org).

```vue
<template>
  <Icon name="lucide:sun" />
</template>
```

## Learn More

- [Nuxt Documentation](https://nuxt.com/docs/getting-started/introduction)
- [shadcn-vue Documentation](https://www.shadcn-vue.com/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Deployment Guide](https://nuxt.com/docs/getting-started/deployment)

## Development Guidelines

For detailed coding standards, commit guidelines, and development practices, see [AGENTS.md](./AGENTS.md).
