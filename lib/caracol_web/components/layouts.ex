defmodule CaracolWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use CaracolWeb, :html
  import CaracolWeb.ThemeComponents, only: [theme_dropdown: 1, theme_toggle: 1]

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
          <li>
            <a href="https://hexdocs.pm/phoenix/overview.html" class="btn btn-primary">
              Get Started <span aria-hidden="true">&rarr;</span>
            </a>
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Renders the authenticated application shell with sidebar navigation.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_scope, :map, required: true, doc: "the current user scope"
  attr :current_path, :string, default: nil, doc: "the current path for active nav state"
  slot :inner_block, required: true

  def app_shell(assigns) do
    ~H"""
    <div class="drawer min-h-screen bg-base-200 lg:drawer-open">
      <input id="app-shell-drawer" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex min-h-screen flex-col">
        <header class="sticky top-0 z-20 border-b border-base-300 bg-base-100/95 backdrop-blur">
          <div class="flex items-center justify-between px-4 py-3 sm:px-6">
            <label for="app-shell-drawer" class="btn btn-square btn-ghost lg:hidden">
              <.icon name="hero-bars-3" class="size-5" />
            </label>
            <div class="text-sm font-semibold text-base-content/75">Application</div>
            <div id="app-user-menu" class="dropdown dropdown-end">
              <button type="button" tabindex="0" class="btn btn-sm btn-ghost gap-2">
                <.icon name="hero-user-circle" class="size-5" />
                <span class="hidden max-w-56 truncate sm:inline">
                  {@current_scope.user.email}
                </span>
              </button>
              <ul
                tabindex="0"
                class="menu dropdown-content z-20 mt-2 w-56 rounded-box border border-base-300 bg-base-100 p-2 shadow"
              >
                <li class="menu-title px-3 py-2 text-[0.7rem] uppercase tracking-[0.16em] text-base-content/60">
                  Account
                </li>
                <li>
                  <.link id="app-user-settings" navigate={~p"/users/settings"}>
                    <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
                  </.link>
                </li>
                <li>
                  <div class="flex items-center justify-between gap-3 px-3 py-2">
                    <span class="inline-flex items-center gap-2 text-sm">
                      <.icon name="hero-swatch" class="size-4" /> Theme
                    </span>
                    <.theme_dropdown id="app-theme-dropdown" />
                  </div>
                </li>
                <li>
                  <.link id="app-user-logout" href={~p"/users/log-out"} method="delete">
                    <.icon name="hero-arrow-right-start-on-rectangle" class="size-4" /> Log out
                  </.link>
                </li>
              </ul>
            </div>
          </div>
        </header>

        <main class="flex-1 px-4 py-6 sm:px-6 lg:px-8">
          {render_slot(@inner_block)}
        </main>
      </div>

      <div class="drawer-side z-30">
        <label for="app-shell-drawer" class="drawer-overlay"></label>
        <aside
          id="app-shell-sidebar"
          class="min-h-full w-72 border-r border-base-300 bg-base-100 px-4 py-5 sm:px-5"
        >
          <.link
            navigate={~p"/app"}
            class="inline-flex items-center gap-2 text-lg font-bold tracking-tight transition hover:text-primary"
          >
            <.icon name="hero-command-line" class="size-5 text-primary" /> Caracol
          </.link>

          <nav class="mt-8">
            <ul class="menu gap-1 p-0">
              <li>
                <.link
                  id="app-nav-home"
                  navigate={~p"/app"}
                  class={nav_link_classes(@current_path == ~p"/app")}
                >
                  <.icon name="hero-home" class="size-4" /> Home
                </.link>
              </li>
              <li>
                <.link
                  id="app-nav-playground"
                  navigate={~p"/playground"}
                  class={nav_link_classes(@current_path == ~p"/playground")}
                >
                  <.icon name="hero-beaker" class="size-4" /> Playground
                </.link>
              </li>
              <li>
                <.link
                  id="app-nav-settings"
                  navigate={~p"/users/settings"}
                  class={nav_link_classes(@current_path == ~p"/users/settings")}
                >
                  <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
                </.link>
              </li>
            </ul>
          </nav>
        </aside>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  defp nav_link_classes(active?) do
    [
      "inline-flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium transition",
      if(active?,
        do: "bg-primary text-primary-content shadow-sm",
        else: "text-base-content/80 hover:bg-base-200 hover:text-base-content"
      )
    ]
  end
end
