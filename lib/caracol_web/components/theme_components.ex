defmodule CaracolWeb.ThemeComponents do
  @moduledoc """
  Reusable theme selection UI components.
  """
  use CaracolWeb, :html

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center rounded-full border-2 border-base-300 bg-base-300">
      <div class="absolute left-0 h-full w-1/3 rounded-full border-1 border-base-200 bg-base-100 brightness-200 transition-[left] [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3" />

      <button
        class="flex w-1/3 cursor-pointer p-2"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex w-1/3 cursor-pointer p-2"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex w-1/3 cursor-pointer p-2"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  @doc """
  Renders a compact dropdown for selecting the current theme.
  """
  attr :id, :string, default: "theme-dropdown", doc: "the dropdown id"

  def theme_dropdown(assigns) do
    ~H"""
    <div id={@id} class="dropdown dropdown-end">
      <button tabindex="0" type="button" class="btn btn-sm btn-ghost gap-2">
        <.icon name="hero-swatch" class="size-4" /> Theme
      </button>
      <ul
        tabindex="0"
        class="menu dropdown-content z-20 mt-2 w-44 rounded-box border border-base-300 bg-base-100 p-2 shadow"
      >
        <li>
          <button
            phx-click={JS.dispatch("phx:set-theme")}
            data-phx-theme="system"
            data-theme-option="system"
            class="theme-option flex w-full items-center justify-between"
            type="button"
          >
            <span class="inline-flex items-center gap-2">
              <.icon name="hero-computer-desktop" class="size-4" /> System
            </span>
            <.icon
              name="hero-check-mini"
              class="theme-selected-indicator invisible size-4 text-success"
            />
          </button>
        </li>
        <li>
          <button
            phx-click={JS.dispatch("phx:set-theme")}
            data-phx-theme="light"
            data-theme-option="light"
            class="theme-option flex w-full items-center justify-between"
            type="button"
          >
            <span class="inline-flex items-center gap-2">
              <.icon name="hero-sun" class="size-4" /> Light
            </span>
            <.icon
              name="hero-check-mini"
              class="theme-selected-indicator invisible size-4 text-success"
            />
          </button>
        </li>
        <li>
          <button
            phx-click={JS.dispatch("phx:set-theme")}
            data-phx-theme="dark"
            data-theme-option="dark"
            class="theme-option flex w-full items-center justify-between"
            type="button"
          >
            <span class="inline-flex items-center gap-2">
              <.icon name="hero-moon" class="size-4" /> Dark
            </span>
            <.icon
              name="hero-check-mini"
              class="theme-selected-indicator invisible size-4 text-success"
            />
          </button>
        </li>
      </ul>
    </div>
    """
  end

  @doc """
  Renders a menu submenu for selecting the current theme.
  """
  attr :id, :string, default: "theme-submenu", doc: "the submenu id"

  def theme_submenu(assigns) do
    ~H"""
    <li id={@id} class="group/theme relative">
      <button
        type="button"
        class="flex w-full items-center justify-between"
        aria-haspopup="menu"
        aria-label="Open theme menu"
      >
        <span class="inline-flex items-center gap-2">
          <.icon name="hero-swatch" class="size-4" /> Theme
        </span>
        <.icon name="hero-chevron-right" class="size-3 text-base-content/60" />
      </button>
      <ul class="menu invisible absolute top-0 left-full z-30 -ml-2 w-40 [margin-inline-start:0] rounded-box border border-base-300 bg-base-100 p-2 opacity-0 shadow [&:before]:hidden transition duration-150 ease-out group-hover/theme:visible group-hover/theme:opacity-100 group-focus-within/theme:visible group-focus-within/theme:opacity-100">
        <li>
          <button
            phx-click={JS.dispatch("phx:set-theme")}
            data-phx-theme="system"
            data-theme-option="system"
            class="theme-option flex w-full items-center justify-between"
            type="button"
          >
            <span class="inline-flex items-center gap-2">
              <.icon name="hero-computer-desktop" class="size-4" /> System
            </span>
            <.icon
              name="hero-check-mini"
              class="theme-selected-indicator invisible size-4 text-success"
            />
          </button>
        </li>
        <li>
          <button
            phx-click={JS.dispatch("phx:set-theme")}
            data-phx-theme="light"
            data-theme-option="light"
            class="theme-option flex w-full items-center justify-between"
            type="button"
          >
            <span class="inline-flex items-center gap-2">
              <.icon name="hero-sun" class="size-4" /> Light
            </span>
            <.icon
              name="hero-check-mini"
              class="theme-selected-indicator invisible size-4 text-success"
            />
          </button>
        </li>
        <li>
          <button
            phx-click={JS.dispatch("phx:set-theme")}
            data-phx-theme="dark"
            data-theme-option="dark"
            class="theme-option flex w-full items-center justify-between"
            type="button"
          >
            <span class="inline-flex items-center gap-2">
              <.icon name="hero-moon" class="size-4" /> Dark
            </span>
            <.icon
              name="hero-check-mini"
              class="theme-selected-indicator invisible size-4 text-success"
            />
          </button>
        </li>
      </ul>
    </li>
    """
  end
end
