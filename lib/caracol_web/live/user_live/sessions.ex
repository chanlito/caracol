defmodule CaracolWeb.UserLive.Sessions do
  use CaracolWeb, :live_view

  alias Caracol.Accounts
  alias Caracol.Accounts.UserToken
  import CaracolWeb.SettingsComponents, only: [settings_panel: 1]

  @impl true
  def mount(_params, session, socket) do
    current_session_token = Map.get(session, "user_token")
    sessions = Accounts.list_user_sessions(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:current_session_token, current_session_token)
     |> assign(:sessions, sessions)}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    sessions = Accounts.list_user_sessions(socket.assigns.current_scope)
    {:noreply, assign(socket, :sessions, sessions)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app_shell
      flash={@flash}
      current_scope={@current_scope}
      current_path={~p"/users/sessions"}
    >
      <.settings_panel current_path={~p"/users/sessions"}>
        <section id="sessions-settings" class="max-w-4xl space-y-5">
          <div class="flex items-start justify-between gap-4">
            <.header>
              Sessions
              <:subtitle>Active sign-ins</:subtitle>
            </.header>
            <button
              id="sessions-refresh"
              type="button"
              phx-click="refresh"
              class="btn btn-sm btn-outline"
            >
              <.icon name="hero-arrow-path" class="size-4" /> Refresh
            </button>
          </div>

          <div id="sessions-list" class="space-y-3" phx-hook="LocalTime">
            <div
              :if={@sessions == []}
              id="sessions-empty"
              class="rounded-xl border border-dashed border-base-300 p-8 text-sm text-base-content/70"
            >
              No active sessions found.
            </div>

            <div
              :if={@sessions != []}
              class="divide-y divide-base-300"
            >
              <article
                :for={session <- @sessions}
                id={"session-#{session.id}"}
                class="py-4"
              >
                <div class="flex flex-wrap items-center justify-between gap-3">
                  <h3 class="text-sm font-semibold text-base-content/90">
                    Signed in
                    <time
                      id={"session-signed-in-#{session.id}"}
                      datetime={datetime_attr(session.inserted_at)}
                      data-local-datetime={datetime_attr(session.inserted_at)}
                    >
                      {format_datetime_fallback(session.inserted_at)}
                    </time>
                  </h3>

                  <span
                    :if={current_session?(session, @current_session_token)}
                    id={"session-current-#{session.id}"}
                    class="badge badge-primary badge-outline font-medium"
                  >
                    Current session
                  </span>
                </div>

                <p :if={show_last_authenticated?(session)} class="mt-2 text-sm text-base-content/70">
                  Last authenticated
                  <time
                    id={"session-authenticated-#{session.id}"}
                    datetime={datetime_attr(session.authenticated_at)}
                    data-local-datetime={datetime_attr(session.authenticated_at)}
                  >
                    {format_datetime_fallback(session.authenticated_at)}
                  </time>
                </p>
              </article>
            </div>
          </div>
        </section>
      </.settings_panel>
    </Layouts.app_shell>
    """
  end

  defp current_session?(%UserToken{token: token}, current_session_token)
       when is_binary(token) and is_binary(current_session_token),
       do: token == current_session_token

  defp current_session?(_session, _current_session_token), do: false

  defp show_last_authenticated?(%UserToken{
         inserted_at: inserted_at,
         authenticated_at: authenticated_at
       })
       when is_struct(inserted_at, DateTime) and is_struct(authenticated_at, DateTime),
       do: abs(DateTime.diff(authenticated_at, inserted_at, :second)) > 60

  defp show_last_authenticated?(_session), do: false

  defp datetime_attr(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp datetime_attr(_), do: nil

  defp format_datetime_fallback(%DateTime{} = dt),
    do: Calendar.strftime(dt, "%b %-d, %Y at %-I:%M %p")

  defp format_datetime_fallback(_), do: "Unavailable"
end
