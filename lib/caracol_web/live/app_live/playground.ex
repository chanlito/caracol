defmodule CaracolWeb.AppLive.Playground do
  use CaracolWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app_shell flash={@flash} current_scope={@current_scope} current_path={~p"/playground"}>
      <section id="playground-page" class="mx-auto max-w-5xl">
        <div class="rounded-box border border-dashed border-base-300 bg-base-100 p-6 shadow-sm sm:p-8">
          <p class="text-sm font-semibold uppercase tracking-[0.18em] text-base-content/60">
            Playground
          </p>
          <h1 class="mt-3 text-3xl font-bold tracking-tight sm:text-4xl">Placeholder page</h1>
          <p class="mt-4 max-w-2xl text-base leading-7 text-base-content/75">
            Use this area to test new interface ideas and interactive components.
          </p>
        </div>
      </section>
    </Layouts.app_shell>
    """
  end
end
