# CLAUDE.md

## Project Overview

**Caracol** is a Phoenix 1.8 web application (Elixir) for personal link management with real-time updates via LiveView, PostgreSQL, Tailwind CSS v4, and DaisyUI.

**Stack:** Elixir ~> 1.15, Phoenix 1.8.4, LiveView 1.1.26, Ecto 3.13.5, Heroicons v2.2.0, Tailwind 0.4.1 (v4)

## Commands

```bash
# Setup
mix setup                    # Install deps, create DB, run migrations, build assets

# Development
mix phx.server               # Start server at http://localhost:4000

# Quality gate (run before finishing changes)
mix precommit                # compile (warnings as errors) + format + test

# Testing
mix test                     # Run all tests
mix test test/path/file.exs  # Run specific file
mix test --failed            # Re-run previously failed tests

# Database
mix ecto.gen.migration name  # Generate migration (always use this, not manual files)
mix ecto.reset               # Drop, create, migrate, seed

# Assets
mix assets.build             # Build CSS + JS once
mix assets.deploy            # Minify for production
```

## Architecture

### Directory Layout

- `lib/caracol/` — Business logic contexts (Accounts, Links)
- `lib/caracol_web/` — Web layer (router, LiveViews, controllers, components)
- `assets/js/` — JavaScript entry point and hooks
- `assets/css/` — Tailwind CSS entry point
- `priv/repo/migrations/` — Ecto migrations

### Authentication (phx.gen.auth with scopes)

- `@current_scope` is the auth assign — **never** use `@current_user` in templates; use `@current_scope.user`
- Pass `current_scope` as the first argument to all context functions
- Routes requiring auth go inside the **existing** `live_session :require_authenticated_user` block
- Routes that work with/without auth go inside the **existing** `live_session :current_user` block
- Sensitive operations require "sudo mode" (re-authenticated within 20 minutes)
- Router `scope` blocks have an implicit alias — never re-alias inside a scope to avoid duplicate module prefixes (e.g. `AppWeb.Admin` scope + `live "/users", Admin.UserLive` → resolves to `AppWeb.Admin.Admin.UserLive`)

### Real-time Updates (PubSub)

- Per-user topic: `"user_links:#{user_id}"` — subscribe with `Links.subscribe_user_links/1`
- Global favorites topic: `"links:favorites"` — subscribe with `Links.subscribe_global_favorites/0`
- LiveViews handle `handle_info/2` for broadcasted link events

## Key Conventions

### Elixir

- Access list items with `Enum.at/2` or pattern matching, never `list[i]`
- Bind results of `if`/`case`/`cond` to variables outside the expression — you cannot rebind inside a block
- Access struct fields with dot syntax (`struct.field`) or `Ecto.Changeset.get_field/2`; never use map access syntax on structs
- Predicate functions end with `?`, not `is_` prefix
- Never nest multiple modules in one file
- Never call `String.to_atom/1` on user input (memory leak)

### Phoenix

- Use `<.icon name="hero-x-mark" class="w-5 h-5"/>` — never use `Heroicons` modules directly
- Use `Req` for HTTP requests — never `:httpoison`, `:tesla`, or `:httpc`
- `<.flash_group>` is forbidden outside `layouts.ex` — Phoenix 1.8 moved it to the `Layouts` module

### HEEx Templates

- Use `{@assign}` for inline interpolation in tag bodies and attributes
- Use `<%= expr %>` only for block constructs (`if`, `for`, `case`, `cond`) in tag bodies
- **Never** use `<%= %>` inside tag attributes
- Conditional classes: always use list syntax `class={["base-class", @flag && "conditional-class"]}`
- Use `<%!-- comment --%>` for template comments
- Never use `else if` / `elseif` — use `cond` for multiple branches
- Wrap `if` in class lists with parens: `if(@cond, do: "a", else: "b")`
- Never use `<% Enum.each ... %>` for template content — always use `:for={item <- @list}` attribute
- Use `phx-no-curly-interpolation` on parent tag when content contains literal `{` or `}` (e.g. code snippets)

```heex
<%!-- Valid --%>
<div id={@id}>{@title}</div>
<%= if @show do %><span>visible</span><% end %>

<%!-- Invalid — never do this --%>
<div id="<%= @id %>">
  {if @show do}<span>visible</span>{end}
</div>
```

### Forms

- Always assign form via `to_form/2` on the socket, never pass changesets directly to templates
- Never use `<.form let={f}>` syntax
- Always give forms an explicit, unique DOM `id` (e.g. `id="link-form"`) for testability
- Always use the imported `<.input>` component for form inputs — never raw `<input>` tags

```heex
<%!-- Good --%>
<.form for={@form} id="link-form" phx-submit="save">
  <.input field={@form[:url]} type="url" />
</.form>

<%!-- Bad — never pass changeset directly --%>
<.form for={@changeset} id="link-form">
  <.input field={@changeset[:url]} />
</.form>
```

### Ecto

- Schema fields always use `:string` type even for text columns
- Fields set programmatically (like `user_id`) must **not** be in `cast/3` calls
- Always use `mix ecto.gen.migration` to generate migration files
- Always preload associations in queries when they'll be accessed in templates

### LiveView

- All LiveView templates must start with `<Layouts.app flash={@flash} current_scope={@current_scope}>`
- **Always** use streams for collections: `stream/3`, `stream_insert/3`, `stream_delete/3`
- Stream template requires `phx-update="stream"` on parent and `id={id}` on each child

**Stream template boilerplate:**
```heex
<div id="links" phx-update="stream">
  <div :for={{id, link} <- @streams.links} id={id}>{link.title}</div>
</div>
```

**Filter/reset pattern** (streams are not enumerable — refetch and reset):
```elixir
def handle_event("filter", %{"q" => q}, socket) do
  links = Links.list_links(socket.assigns.current_scope, q)
  {:noreply, socket |> assign(:empty?, links == []) |> stream(:links, links, reset: true)}
end
```

**Empty state via CSS** (sibling trick — no extra assign needed):
```heex
<div id="links" phx-update="stream">
  <div class="hidden only:block">No links yet</div>
  <div :for={{id, link} <- @streams.links} id={id}>{link.title}</div>
</div>
```

**Re-stream when a streamed item's UI state changes:**
```elixir
socket
|> stream_insert(:links, link)
|> assign(:editing_id, link.id)
```

**Server→client (push_event):**
```elixir
# LiveView
socket = push_event(socket, "my_event", %{key: val})
```
```javascript
// Hook
mounted() { this.handleEvent("my_event", data => ...) }
```

**Client→server (pushEvent):**
```javascript
// Hook
this.pushEvent("my_event", {key: val}, reply => ...)
```
```elixir
# LiveView
def handle_event("my_event", %{"key" => val}, socket), do: {:reply, %{}, socket}
```

- Never use `phx-update="append"` or `phx-update="prepend"` — use streams instead
- Never use deprecated `live_redirect`/`live_patch`; use `<.link navigate={href}>` / `<.link patch={href}>` in templates, `push_navigate`/`push_patch` in LiveViews
- Avoid LiveComponents unless there's a strong specific need
- Name LiveViews using a `<Namespace>Live.<Action>` pattern (e.g. `CaracolWeb.LinkLive.Index`, `CaracolWeb.UserLive.Settings`), colocated under `live/<namespace>_live/` directories
- A single LiveView can handle multiple routes via `:live_action` — the `@live_action` assign reflects the matched action (`:index`, `:new`, `:edit`, etc.) and is used to conditionally render modals, forms, or panels within the same module
- Always provide a unique DOM `id` alongside `phx-hook`; also add `phx-update="ignore"` when the hook manages its own DOM

### JavaScript Hooks

- Colocated hooks: use `:type={Phoenix.LiveView.ColocatedHook}` script tag inside HEEx; name **must** start with `.` (e.g., `.PhoneNumber`)
- External hooks: define in `assets/js/` and register in `LiveSocket` constructor

### CSS / Assets

- Tailwind v4 — no `tailwind.config.js`; uses `@import "tailwindcss" source(none)` with `@source` directives in `app.css`
- **Never** use `@apply` in raw CSS
- Only `app.js` and `app.css` bundles are supported — vendor deps must be imported into these files, not linked externally
- **Never** write inline `<script>` tags in templates

### Tests

- Use `start_supervised!/1` to start processes
- Avoid `Process.sleep/1` — use `Process.monitor/1` + `:DOWN` for process death, `:sys.get_state(pid)` to sync before next call
- Use `element/2`, `has_element?/2` for LiveView assertions — never test raw HTML strings
- Use `render_submit/2` and `render_change/2` for form interaction tests
- Use `LazyHTML` to debug failing selectors: `LazyHTML.from_fragment(render(view)) |> LazyHTML.filter("selector")`

## Commit Guidelines

Use Conventional Commits with a fitting emoji: `type(scope): :emoji: message`

```
feat(links): ✨ add bulk delete
fix(auth): 🐛 redirect loop on expired session
refactor(links): ♻️ extract filter logic to context
perf(queries): ⚡️ add index on inserted_at
test(links): ✅ cover archive flow
chore(deps): 📦 bump phoenix to 1.8.5
docs: 📝 update setup instructions
```

Common types: `feat`, `fix`, `refactor`, `perf`, `test`, `chore`, `docs`, `style`
