defmodule CaracolWeb.SettingsComponents do
  @moduledoc """
  Shared UI components for user settings pages.
  """
  use CaracolWeb, :html

  attr :current_path, :string, required: true
  slot :inner_block, required: true

  def settings_panel(assigns) do
    assigns =
      assign(assigns, :tabs, [
        %{id: "account", label: "Account", path: ~p"/users/settings"},
        %{id: "appearance", label: "Appearance", path: ~p"/users/appearance"},
        %{id: "sessions", label: "Sessions", path: ~p"/users/sessions"}
      ])

    ~H"""
    <section class="max-w-4xl">
      <nav id="settings-subnav" aria-label="Settings sections">
        <div role="tablist" class="tabs tabs-lift">
          <.link
            :for={tab <- @tabs}
            id={"settings-tab-#{tab.id}"}
            navigate={tab.path}
            role="tab"
            aria-current={if tab.path == @current_path, do: "page", else: nil}
            class={[
              "tab px-4 text-sm font-medium transition",
              if(tab.path == @current_path,
                do: "tab-active text-primary",
                else: "text-base-content/70"
              )
            ]}
          >
            {tab.label}
          </.link>
        </div>
      </nav>

      <div
        id="settings-tab-content"
        class="tabs-content rounded-b-box border-x border-b border-base-300 bg-base-100 p-6"
      >
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end
end
