defmodule CaracolWeb.AppLive.Index do
  use CaracolWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app_shell flash={@flash} current_scope={@current_scope} current_path={~p"/app"}>
      <section id="app-home-page" class="w-full">
        <div class="rounded-box border border-base-300 bg-base-100 p-6 shadow-sm sm:p-8">
          <p class="text-sm font-semibold uppercase tracking-[0.18em] text-base-content/60">
            App Home
          </p>
          <h1 class="mt-3 text-3xl font-bold tracking-tight sm:text-4xl">Welcome to Caracol app</h1>
          <p class="mt-4 max-w-2xl text-base leading-7 text-base-content/75">
            This is your authenticated workspace. Use the sidebar to access the playground and account settings.
          </p>
        </div>
      </section>
    </Layouts.app_shell>
    """
  end
end
