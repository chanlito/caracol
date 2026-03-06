defmodule CaracolWeb.UserLive.Appearance do
  use CaracolWeb, :live_view
  import CaracolWeb.SettingsComponents, only: [settings_panel: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app_shell
      flash={@flash}
      current_scope={@current_scope}
      current_path={~p"/users/appearance"}
      favorite_links={Map.get(assigns, :favorite_links, [])}
    >
      <.settings_panel current_path={~p"/users/appearance"}>
        <section id="appearance-settings" class="space-y-6">
          <.header>
            Appearance
            <:subtitle>Choose your preferred theme for the application.</:subtitle>
          </.header>

          <div
            id="appearance-theme-options"
            class="overflow-hidden rounded-2xl border border-base-300 bg-base-100"
          >
            <button
              id="appearance-theme-system"
              class="appearance-theme-option theme-option flex w-full items-start justify-between gap-4 border-b border-base-300 px-5 py-4 text-left transition hover:bg-base-200 [html[data-theme-preference=system]_&]:bg-base-300"
              type="button"
              phx-click={JS.dispatch("phx:set-theme")}
              data-phx-theme="system"
              data-theme-option="system"
            >
              <span class="inline-flex items-start gap-3">
                <span class="mt-0.5 inline-flex size-6 items-center justify-center text-base-content/70">
                  <.icon name="hero-computer-desktop" class="size-5" />
                </span>
                <span class="space-y-1">
                  <span class="block font-semibold leading-none text-base-content">
                    Auto
                  </span>
                  <span class="block text-sm text-base-content/75">
                    Switch between light and dark mode based on your system settings.
                  </span>
                </span>
              </span>
              <.icon
                name="hero-check-mini"
                class="theme-selected-indicator invisible mt-1 size-5 text-primary"
              />
            </button>

            <button
              id="appearance-theme-light"
              class="appearance-theme-option theme-option flex w-full items-start justify-between gap-4 border-b border-base-300 px-5 py-4 text-left transition hover:bg-base-200 [html[data-theme-preference=light]_&]:bg-base-300"
              type="button"
              phx-click={JS.dispatch("phx:set-theme")}
              data-phx-theme="light"
              data-theme-option="light"
            >
              <span class="inline-flex items-start gap-3">
                <span class="mt-0.5 inline-flex size-6 items-center justify-center text-base-content/70">
                  <.icon name="hero-sun" class="size-5" />
                </span>
                <span class="space-y-1">
                  <span class="block font-semibold leading-none text-base-content">
                    Light Mode
                  </span>
                  <span class="block text-sm text-base-content/75">
                    Always use light mode (white background, black text).
                  </span>
                </span>
              </span>
              <.icon
                name="hero-check-mini"
                class="theme-selected-indicator invisible mt-1 size-5 text-primary"
              />
            </button>

            <button
              id="appearance-theme-dark"
              class="appearance-theme-option theme-option flex w-full items-start justify-between gap-4 px-5 py-4 text-left transition hover:bg-base-200 [html[data-theme-preference=dark]_&]:bg-base-300"
              type="button"
              phx-click={JS.dispatch("phx:set-theme")}
              data-phx-theme="dark"
              data-theme-option="dark"
            >
              <span class="inline-flex items-start gap-3">
                <span class="mt-0.5 inline-flex size-6 items-center justify-center text-base-content/70">
                  <.icon name="hero-moon" class="size-5" />
                </span>
                <span class="space-y-1">
                  <span class="block font-semibold leading-none text-base-content">
                    Dark Mode
                  </span>
                  <span class="block text-sm text-base-content/75">
                    Always use dark mode (black background, white text).
                  </span>
                </span>
              </span>
              <.icon
                name="hero-check-mini"
                class="theme-selected-indicator invisible mt-1 size-5 text-primary"
              />
            </button>
          </div>
        </section>
      </.settings_panel>
    </Layouts.app_shell>
    """
  end
end
