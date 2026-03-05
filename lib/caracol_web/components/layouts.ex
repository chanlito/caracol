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

    <main class="px-4 py-20 sm:px-6">
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
    assigns = assign(assigns, :user_initials, user_initials(assigns.current_scope.user.email))

    ~H"""
    <div class="drawer min-h-screen bg-base-200 lg:drawer-open">
      <input id="app-shell-drawer" type="checkbox" class="drawer-toggle" phx-hook="Sidebar" />

      <div class="drawer-content flex min-h-screen flex-col">
        <header class="sticky top-0 z-20 border-b border-base-300 bg-base-100/95 backdrop-blur">
          <div class="grid h-16 grid-cols-[auto_1fr_auto] items-center px-4 sm:px-6">
            <div class="flex items-center gap-2">
              <label
                for="app-shell-drawer"
                id="app-shell-mobile-toggle"
                aria-label="open sidebar"
                class="btn btn-square btn-ghost lg:hidden"
              >
                <.icon name="hero-bars-3" class="size-5" />
              </label>
            </div>
            <div class="justify-self-center text-sm font-semibold text-base-content/75">
              Application
            </div>
            <div aria-hidden="true" class="w-10"></div>
          </div>
        </header>

        <main class="flex-1 px-4 py-6 sm:px-6">
          {render_slot(@inner_block)}
        </main>
      </div>

      <div class="drawer-side z-30 lg:overflow-visible">
        <label for="app-shell-drawer" class="drawer-overlay"></label>
        <aside
          id="app-shell-sidebar"
          class="flex h-full min-h-full w-72 flex-col border-r border-base-300 bg-base-100 px-3 transition-[width,padding] duration-200 ease-out"
        >
          <.link
            navigate={~p"/home"}
            class="app-shell-brand-link app-shell-nav-link grid w-full min-h-10 my-2 grid-cols-[2rem_minmax(0,1fr)] items-center gap-2 rounded-lg px-3 py-2 text-base font-bold tracking-tight transition hover:bg-base-200 hover:text-primary"
          >
            <span class="app-shell-row-icon inline-flex size-8 items-center justify-center">
              <.icon name="hero-command-line" class="size-5 text-primary" />
            </span>
            <span class="app-shell-brand-label app-shell-row-label">Caracol</span>
          </.link>

          <nav class="mt-4 pt-2">
            <ul class="menu w-full gap-2 p-0">
              <li class="w-full">
                <.link
                  id="app-nav-home"
                  navigate={~p"/home"}
                  class={nav_link_classes(@current_path == ~p"/home")}
                  data-tip="Home"
                >
                  <span class="app-shell-row-icon inline-flex size-8 items-center justify-center">
                    <.icon name="hero-home" class="size-4 shrink-0" />
                  </span>
                  <span class="app-shell-nav-label app-shell-row-label">Home</span>
                </.link>
              </li>
              <li class="w-full">
                <.link
                  id="app-nav-playground"
                  navigate={~p"/playground"}
                  class={nav_link_classes(@current_path == ~p"/playground")}
                  data-tip="Playground"
                >
                  <span class="app-shell-row-icon inline-flex size-8 items-center justify-center">
                    <.icon name="hero-beaker" class="size-4 shrink-0" />
                  </span>
                  <span class="app-shell-nav-label app-shell-row-label">Playground</span>
                </.link>
              </li>
              <li class="w-full">
                <.link
                  id="app-nav-settings"
                  navigate={~p"/users/settings"}
                  class={nav_link_classes(@current_path == ~p"/users/settings")}
                  data-tip="Settings"
                >
                  <span class="app-shell-row-icon inline-flex size-8 items-center justify-center">
                    <.icon name="hero-cog-6-tooth" class="size-4 shrink-0" />
                  </span>
                  <span class="app-shell-nav-label app-shell-row-label">Settings</span>
                </.link>
              </li>
            </ul>
          </nav>

          <div class="mt-auto">
            <label
              for="app-shell-drawer"
              id="app-sidebar-desktop-toggle"
              aria-label="toggle sidebar"
              class="app-shell-nav-link mb-2 hidden w-full min-h-10 cursor-pointer grid-cols-[2rem_minmax(0,1fr)] items-center gap-2 rounded-lg px-3 py-2.5 text-left text-sm font-medium text-base-content/80 transition hover:bg-base-200 hover:text-base-content lg:grid"
            >
              <span class="app-shell-row-icon inline-flex size-8 items-center justify-center">
                <.icon
                  name="hero-chevron-double-left"
                  class="app-sidebar-toggle-close inline-flex size-4 shrink-0"
                />
                <.icon
                  name="hero-chevron-double-right"
                  class="app-sidebar-toggle-open hidden size-4 shrink-0"
                />
              </span>
              <span class="app-shell-row-label app-shell-account-label text-sm font-medium text-base-content/85">
                <span class="app-sidebar-toggle-label-close inline">Collapse</span>
                <span class="app-sidebar-toggle-label-open hidden">Expand</span>
              </span>
            </label>

            <div id="app-sidebar-account" class="border-t border-base-300 py-3">
              <div id="app-sidebar-user-menu" class="dropdown dropdown-top w-full">
                <button
                  type="button"
                  tabindex="0"
                  aria-label="Open account menu"
                  class="app-shell-account-trigger app-shell-nav-link grid w-full min-h-10 cursor-pointer grid-cols-[2rem_minmax(0,1fr)] items-center gap-2 rounded-lg px-3 py-2.5 text-left text-sm font-medium text-base-content/80 transition hover:bg-base-200 hover:text-base-content"
                >
                  <span class="app-shell-row-icon inline-flex size-8 items-center justify-center">
                    <span class="app-shell-account-avatar inline-flex size-8 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-semibold text-primary-content">
                      {@user_initials}
                    </span>
                  </span>
                  <span class="app-shell-account-label app-shell-row-label text-sm font-medium text-base-content/85">
                    <span class="block truncate">{@current_scope.user.email}</span>
                  </span>
                </button>

                <ul
                  tabindex="0"
                  class="menu dropdown-content z-20 mb-2 w-56 rounded-box border border-base-300 bg-base-100 p-2 shadow"
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
          </div>
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
      "app-shell-nav-link grid w-full min-h-10 grid-cols-[2rem_minmax(0,1fr)] items-center gap-2 rounded-lg px-3 py-2.5 text-sm font-medium transition",
      if(active?,
        do: "bg-primary text-primary-content shadow-sm",
        else: "text-base-content/80 hover:bg-base-200 hover:text-base-content"
      )
    ]
  end

  defp user_initials(nil), do: "U"

  defp user_initials(email) do
    email
    |> String.split("@", parts: 2)
    |> List.first()
    |> case do
      nil ->
        "U"

      local_part ->
        local_part
        |> String.split(~r/[._-]+/, trim: true)
        |> Enum.map(&String.slice(&1, 0, 1))
        |> Enum.reject(&(&1 in [nil, ""]))
        |> Enum.take(2)
        |> Enum.join()
        |> String.upcase()
        |> case do
          "" -> "U"
          initials -> initials
        end
    end
  end
end
