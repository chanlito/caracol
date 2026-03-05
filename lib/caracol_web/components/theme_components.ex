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
          <button phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="system" type="button">
            <.icon name="hero-computer-desktop" class="size-4" /> System
          </button>
        </li>
        <li>
          <button phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="light" type="button">
            <.icon name="hero-sun" class="size-4" /> Light
          </button>
        </li>
        <li>
          <button phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="dark" type="button">
            <.icon name="hero-moon" class="size-4" /> Dark
          </button>
        </li>
      </ul>
    </div>
    """
  end
end
