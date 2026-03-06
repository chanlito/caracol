defmodule CaracolWeb.UserLive.Sessions do
  use CaracolWeb, :live_view

  alias Caracol.Accounts
  alias Caracol.Accounts.UserToken
  alias CaracolWeb.UserAuth
  import CaracolWeb.SettingsComponents, only: [settings_panel: 1]
  @per_page 10

  @impl true
  def mount(_params, session, socket) do
    current_session_token = Map.get(session, "user_token")
    utc_offset_minutes = socket_utc_offset_minutes(socket)

    if connected?(socket) do
      Accounts.subscribe_user_sessions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:current_session_token, current_session_token)
     |> assign(:sessions, [])
     |> assign(:page, 1)
     |> assign(:per_page, @per_page)
     |> assign(:total_sessions, 0)
     |> assign(:total_pages, 1)
     |> assign(:page_clamped?, false)
     |> assign(:utc_offset_minutes, utc_offset_minutes)
     |> assign(:show_expired, false)
     |> assign(:revoke_session_id, nil)
     |> assign(:revoke_form, revoke_form())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    requested_page = parse_page_param(Map.get(params, "page"))

    socket =
      socket
      |> assign(:page, requested_page)
      |> refresh_sessions()
      |> apply_live_action(socket.assigns.live_action, params)
      |> maybe_patch_clamped_page(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply, socket |> refresh_sessions() |> maybe_patch_clamped_page(:index, %{})}
  end

  def handle_event("toggle_expired", _params, socket) do
    socket =
      socket
      |> assign(:show_expired, not socket.assigns.show_expired)
      |> refresh_sessions()
      |> maybe_patch_clamped_page(:index, %{})

    {:noreply, socket}
  end

  def handle_event("prev_page", _params, socket) do
    page = max(socket.assigns.page - 1, 1)
    {:noreply, push_patch(socket, to: sessions_index_path(page))}
  end

  def handle_event("next_page", _params, socket) do
    page = min(socket.assigns.page + 1, socket.assigns.total_pages)
    {:noreply, push_patch(socket, to: sessions_index_path(page))}
  end

  def handle_event("cancel_revoke", _params, socket) do
    {:noreply, push_patch(socket, to: sessions_index_path(socket.assigns.page))}
  end

  def handle_event("validate_revoke", %{"revoke" => params}, socket) do
    {:noreply, assign(socket, :revoke_form, revoke_form(params, :validate))}
  end

  def handle_event("confirm_revoke", %{"revoke" => params}, socket) do
    session_id = socket.assigns.revoke_session_id
    changeset = revoke_changeset(params)

    if changeset.valid? and is_binary(session_id) do
      case Accounts.revoke_user_session(socket.assigns.current_scope, session_id) do
        {:ok, revoked_session} ->
          UserAuth.disconnect_sessions([revoked_session])

          socket =
            socket
            |> refresh_sessions()
            |> assign(:revoke_session_id, nil)
            |> assign(:revoke_form, revoke_form())

          if current_session?(revoked_session, socket.assigns.current_session_token) do
            {:noreply,
             socket
             |> put_flash(:info, "Session revoked. Please sign in again.")
             |> redirect(to: ~p"/users/log-in")}
          else
            {:noreply,
             socket
             |> put_flash(:info, "Session revoked.")
             |> push_patch(to: sessions_index_path(socket.assigns.page))}
          end

        {:error, :not_found} ->
          {:noreply,
           socket
           |> put_flash(:error, "Session not found.")
           |> push_patch(to: sessions_index_path(socket.assigns.page))}
      end
    else
      {:noreply, assign(socket, :revoke_form, revoke_form(params, :insert))}
    end
  end

  @impl true
  def handle_info(:sessions_changed, socket) do
    socket = refresh_sessions(socket)

    socket =
      if socket.assigns.live_action == :revoke and
           is_binary(socket.assigns.revoke_session_id) and
           is_nil(
             Accounts.get_user_session(
               socket.assigns.current_scope,
               socket.assigns.revoke_session_id,
               include_expired: true
             )
           ) do
        socket
        |> assign(:revoke_session_id, nil)
        |> assign(:revoke_form, revoke_form())
        |> push_patch(to: sessions_index_path(socket.assigns.page))
      else
        maybe_patch_clamped_page(socket, socket.assigns.live_action, %{
          "id" => socket.assigns.revoke_session_id
        })
      end

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app_shell
      flash={@flash}
      current_scope={@current_scope}
      current_path={~p"/users/sessions"}
      favorite_links={Map.get(assigns, :favorite_links, [])}
    >
      <.settings_panel current_path={~p"/users/sessions"}>
        <section id="sessions-settings" class="w-full space-y-5">
          <div class="flex items-start justify-between gap-4">
            <.header>
              Sessions
              <:subtitle>Active sign-ins</:subtitle>
            </.header>
            <div class="flex items-center gap-2">
              <button
                id="sessions-toggle-expired"
                type="button"
                phx-click="toggle_expired"
                class="btn btn-sm btn-outline"
              >
                <.icon name="hero-funnel" class="size-4" />
                {if @show_expired, do: "Hide expired", else: "Show expired"}
              </button>
              <button
                id="sessions-refresh"
                type="button"
                phx-click="refresh"
                class="btn btn-sm btn-outline"
              >
                <.icon name="hero-arrow-path" class="size-4" /> Refresh
              </button>
            </div>
          </div>

          <div id="sessions-list" class="space-y-0">
            <div
              :if={@sessions == []}
              id="sessions-empty"
              class="rounded-xl border border-dashed border-base-300 p-8 text-sm text-base-content/70"
            >
              No active sessions found.
            </div>

            <div
              :if={@sessions != []}
              class="-mx-6 w-[calc(100%+3rem)] overflow-x-auto"
            >
              <.table
                id="sessions-table"
                rows={@sessions}
                row_id={fn session -> "session-#{session.id}" end}
                class="!w-full [&_thead_tr_th:first-child]:!pl-6 [&_tbody_tr_td:first-child]:!pl-6"
              >
                <:col :let={session} label="Login time">
                  <div id={"session-login-#{session.id}"} class="space-y-1">
                    <time
                      id={"session-signed-in-#{session.id}"}
                      datetime={datetime_attr(session.inserted_at)}
                      class="text-sm font-medium text-base-content"
                    >
                      <.local_time
                        datetime={session.inserted_at}
                        utc_offset_minutes={@utc_offset_minutes}
                      />
                    </time>

                    <span
                      :if={current_session?(session, @current_session_token)}
                      id={"session-current-#{session.id}"}
                      class="badge badge-primary badge-outline badge-sm"
                    >
                      Current
                    </span>
                    <span
                      :if={session_expired?(session)}
                      id={"session-expired-#{session.id}"}
                      class="badge badge-warning badge-outline badge-sm"
                    >
                      Expired
                    </span>
                  </div>
                </:col>

                <:col :let={session} label="Browser">
                  <span id={"session-browser-#{session.id}"} class="text-sm text-base-content/85">
                    {session_browser_label(session)}
                  </span>
                </:col>

                <:col :let={session} label="Device OS">
                  <span id={"session-device-os-#{session.id}"} class="text-sm text-base-content/85">
                    {session_device_os_label(session)}
                  </span>
                </:col>

                <:col :let={session} label="Location (IP)">
                  <span id={"session-ip-#{session.id}"} class="font-mono text-xs text-base-content/75">
                    {session_ip_label(session)}
                  </span>
                </:col>

                <:action :let={session}>
                  <.link
                    id={"session-revoke-#{session.id}"}
                    patch={sessions_revoke_path(session.id, @page)}
                    class="btn btn-sm btn-ghost text-error hover:bg-error/10"
                  >
                    <.icon name="hero-trash" class="size-4" /> Revoke
                  </.link>
                </:action>
              </.table>
            </div>

            <div
              :if={@total_sessions > 0}
              id="sessions-pagination"
              class="-mx-6 flex flex-col gap-3 border-t border-base-300 px-6 pt-4 sm:flex-row sm:items-center sm:justify-between"
            >
              <p id="sessions-total-count" class="text-sm text-base-content/70">
                {@total_sessions} total sessions
              </p>

              <div class="flex items-center gap-2">
                <button
                  id="sessions-page-prev"
                  type="button"
                  phx-click="prev_page"
                  disabled={@page <= 1}
                  class="btn btn-sm btn-outline disabled:btn-disabled"
                >
                  <.icon name="hero-chevron-left" class="size-4" /> Prev
                </button>

                <p
                  id="sessions-page-label"
                  class="min-w-28 text-center text-xs font-semibold uppercase tracking-[0.12em] text-base-content/60"
                >
                  Page {@page} of {@total_pages}
                </p>

                <button
                  id="sessions-page-next"
                  type="button"
                  phx-click="next_page"
                  disabled={@page >= @total_pages}
                  class="btn btn-sm btn-outline disabled:btn-disabled"
                >
                  Next <.icon name="hero-chevron-right" class="size-4" />
                </button>
              </div>
            </div>
          </div>
        </section>

        <.modal
          id="revoke-session-modal"
          show={not is_nil(@revoke_session_id)}
          on_cancel="cancel_revoke"
          title="Revoke Session"
          panel_class="max-w-md"
        >
          <:subtitle>Type REVOKE to confirm this action.</:subtitle>

          <.form
            for={@revoke_form}
            id="revoke-session-form"
            phx-change="validate_revoke"
            phx-submit="confirm_revoke"
          >
            <.input
              field={@revoke_form[:confirmation]}
              type="text"
              label="Confirmation"
              autocomplete="off"
              data-autofocus="true"
              required
            />
            <div class="mt-4 flex justify-end gap-2">
              <button
                id="revoke-session-cancel"
                type="button"
                phx-click="cancel_revoke"
                class="btn btn-sm"
              >
                Cancel
              </button>
              <button
                id="revoke-session-confirm"
                type="submit"
                disabled={not revoke_enabled?(@revoke_form)}
                class={[
                  "btn btn-sm btn-error",
                  not revoke_enabled?(@revoke_form) && "btn-disabled opacity-70"
                ]}
              >
                Revoke session
              </button>
            </div>
          </.form>
        </.modal>
      </.settings_panel>
    </Layouts.app_shell>
    """
  end

  defp current_session?(%UserToken{token: token}, current_session_token)
       when is_binary(token) and is_binary(current_session_token),
       do: token == current_session_token

  defp current_session?(_session, _current_session_token), do: false

  defp session_ip_label(%UserToken{ip_address: ip_address}) when is_binary(ip_address) do
    if ip_address == "", do: "Unavailable", else: ip_address
  end

  defp session_ip_label(_session), do: "Unavailable"

  defp session_browser_label(%UserToken{user_agent: user_agent}) do
    %{browser: browser} = parse_user_agent(user_agent)
    browser
  end

  defp session_device_os_label(%UserToken{user_agent: user_agent}) do
    %{browser: browser, os: os, device: device} = parse_user_agent(user_agent)

    if browser == "Unknown browser" and os == "Unknown OS" and device == "Unknown device" do
      "Unknown device / Unknown OS"
    else
      "#{device} / #{os}"
    end
  end

  defp parse_user_agent(user_agent) when is_binary(user_agent) and user_agent != "" do
    %{
      browser: browser_from_user_agent(user_agent),
      os: os_from_user_agent(user_agent),
      device: device_from_user_agent(user_agent)
    }
  end

  defp parse_user_agent(_user_agent),
    do: %{browser: "Unknown browser", os: "Unknown OS", device: "Unknown device"}

  defp browser_from_user_agent(user_agent) do
    cond do
      String.contains?(user_agent, "Edg/") ->
        "Edge"

      String.contains?(user_agent, "OPR/") ->
        "Opera"

      String.contains?(user_agent, "Chrome/") ->
        "Chrome"

      String.contains?(user_agent, "Firefox/") ->
        "Firefox"

      String.contains?(user_agent, "Safari/") and not String.contains?(user_agent, "Chrome/") ->
        "Safari"

      true ->
        "Unknown browser"
    end
  end

  defp os_from_user_agent(user_agent) do
    cond do
      String.contains?(user_agent, "Windows") -> "Windows"
      String.contains?(user_agent, "Mac OS X") -> "macOS"
      String.contains?(user_agent, "Android") -> "Android"
      String.contains?(user_agent, "iPhone") or String.contains?(user_agent, "iPad") -> "iOS"
      String.contains?(user_agent, "Linux") -> "Linux"
      true -> "Unknown OS"
    end
  end

  defp device_from_user_agent(user_agent) do
    cond do
      String.contains?(user_agent, "iPad") or String.contains?(user_agent, "Tablet") -> "Tablet"
      String.contains?(user_agent, "Mobile") or String.contains?(user_agent, "iPhone") -> "Mobile"
      true -> "Desktop"
    end
  end

  defp socket_utc_offset_minutes(socket) do
    with true <- connected?(socket),
         %{} = params <- get_connect_params(socket),
         raw when not is_nil(raw) <- params["utc_offset_minutes"],
         {offset, ""} <- Integer.parse("#{raw}"),
         true <- offset in -840..840 do
      offset
    else
      _ -> nil
    end
  end

  attr :datetime, :any, required: true
  attr :utc_offset_minutes, :any, required: true

  defp local_time(assigns) do
    ~H"""
    <%= if is_integer(@utc_offset_minutes) do %>
      {format_local_datetime(@datetime, @utc_offset_minutes)}
    <% else %>
      <span
        aria-hidden="true"
        class="inline-block h-4 w-28 animate-pulse rounded bg-base-300/70 align-middle"
      />
      <span class="sr-only">Loading local time</span>
    <% end %>
    """
  end

  defp format_local_datetime(%DateTime{} = dt, offset_minutes) when is_integer(offset_minutes) do
    dt
    |> DateTime.add(offset_minutes, :minute)
    |> Calendar.strftime("%b %-d, %Y at %-I:%M %p")
  end

  defp format_local_datetime(_dt, _offset), do: "Unavailable"

  defp apply_live_action(socket, :index, _params) do
    socket
    |> assign(:revoke_session_id, nil)
    |> assign(:revoke_form, revoke_form())
  end

  defp apply_live_action(socket, :revoke, %{"id" => session_id}) do
    if Accounts.get_user_session(socket.assigns.current_scope, session_id, include_expired: true) do
      socket
      |> assign(:revoke_session_id, session_id)
      |> assign(:revoke_form, revoke_form())
    else
      socket
      |> put_flash(:error, "Session not found.")
      |> assign(:revoke_session_id, nil)
      |> assign(:revoke_form, revoke_form())
      |> push_patch(to: sessions_index_path(socket.assigns.page))
    end
  end

  defp revoke_form(params \\ %{}, action \\ nil) do
    changeset = revoke_changeset(params)
    to_form(if(action, do: Map.put(changeset, :action, action), else: changeset), as: :revoke)
  end

  defp revoke_changeset(params) do
    {%{}, %{confirmation: :string}}
    |> Ecto.Changeset.cast(params, [:confirmation])
    |> Ecto.Changeset.validate_required([:confirmation])
    |> Ecto.Changeset.validate_inclusion(:confirmation, ["REVOKE"], message: "must be REVOKE")
  end

  defp revoke_enabled?(%Phoenix.HTML.Form{source: %Ecto.Changeset{} = changeset}) do
    changeset.valid? and Ecto.Changeset.get_field(changeset, :confirmation) == "REVOKE"
  end

  defp revoke_enabled?(_form), do: false

  defp datetime_attr(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp datetime_attr(_), do: nil

  defp refresh_sessions(socket) do
    include_expired = socket.assigns.show_expired

    total_sessions =
      Accounts.count_user_sessions(socket.assigns.current_scope, include_expired: include_expired)

    total_pages = page_count(total_sessions, socket.assigns.per_page)
    requested_page = socket.assigns.page
    page = clamp_page(requested_page, total_pages)
    offset = (page - 1) * socket.assigns.per_page

    sessions =
      Accounts.list_user_sessions(socket.assigns.current_scope,
        include_expired: include_expired,
        limit: socket.assigns.per_page,
        offset: offset
      )

    socket
    |> assign(:sessions, sessions)
    |> assign(:total_sessions, total_sessions)
    |> assign(:total_pages, total_pages)
    |> assign(:page, page)
    |> assign(:page_clamped?, page != requested_page)
  end

  defp maybe_patch_clamped_page(
         %{assigns: %{page_clamped?: false}} = socket,
         _live_action,
         _params
       ),
       do: socket

  defp maybe_patch_clamped_page(
         %{assigns: %{revoke_session_id: session_id}} = socket,
         :revoke,
         %{"id" => session_id}
       )
       when is_binary(session_id) do
    push_patch(socket, to: sessions_revoke_path(session_id, socket.assigns.page))
  end

  defp maybe_patch_clamped_page(socket, _live_action, _params) do
    push_patch(socket, to: sessions_index_path(socket.assigns.page))
  end

  defp parse_page_param(raw_page) when is_binary(raw_page) do
    case Integer.parse(raw_page) do
      {page, ""} when page > 0 -> page
      _ -> 1
    end
  end

  defp parse_page_param(_), do: 1

  defp page_count(0, _per_page), do: 1
  defp page_count(total_sessions, per_page), do: div(total_sessions + per_page - 1, per_page)

  defp clamp_page(page, _total_pages) when page < 1, do: 1
  defp clamp_page(page, total_pages) when page > total_pages, do: total_pages
  defp clamp_page(page, _total_pages), do: page

  defp sessions_index_path(page) when is_integer(page) and page > 1 do
    ~p"/users/sessions?page=#{page}"
  end

  defp sessions_index_path(_page), do: ~p"/users/sessions"

  defp sessions_revoke_path(session_id, page)
       when is_binary(session_id) and is_integer(page) and page > 1 do
    ~p"/users/sessions/#{session_id}/revoke?page=#{page}"
  end

  defp sessions_revoke_path(session_id, _page) when is_binary(session_id) do
    ~p"/users/sessions/#{session_id}/revoke"
  end

  defp session_expired?(%UserToken{inserted_at: %DateTime{} = inserted_at}) do
    expires_at = DateTime.add(inserted_at, UserToken.session_validity_in_days(), :day)
    DateTime.compare(expires_at, DateTime.utc_now(:second)) != :gt
  end

  defp session_expired?(_session), do: true
end
