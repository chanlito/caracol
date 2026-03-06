defmodule CaracolWeb.LinkLive.Index do
  use CaracolWeb, :live_view

  alias Caracol.Links
  alias Caracol.Links.Link

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Links.subscribe_user_links(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> stream_configure(:links, dom_id: &"link-#{&1.id}")
     |> assign(:form, link_form(%Link{}))
     |> assign(:form_params, %{})
     |> assign(:editing_link, nil)
     |> assign(:deleting_link, nil)
     |> assign(:favorite_count, 0)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> refresh_links()
      |> apply_live_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:links_changed, socket) do
    {:noreply, refresh_links(socket)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/links")}
  end

  def handle_event("validate", %{"link" => params}, socket) do
    changeset =
      case socket.assigns.live_action do
        :edit -> Links.change_link(socket.assigns.editing_link, params)
        _ -> Links.change_link(%Link{}, params)
      end

    {:noreply,
     socket
     |> assign(:form_params, params)
     |> assign(:form, to_form(Map.put(changeset, :action, :validate)))}
  end

  def handle_event("select_icon", %{"icon" => icon}, socket) do
    params = Map.put(socket.assigns.form_params, "icon", icon)

    changeset =
      case socket.assigns.live_action do
        :edit -> Links.change_link(socket.assigns.editing_link, params)
        _ -> Links.change_link(%Link{}, params)
      end

    {:noreply,
     socket
     |> assign(:form_params, params)
     |> assign(:form, to_form(Map.put(changeset, :action, :validate)))}
  end

  def handle_event("save", %{"link" => params}, socket) do
    case socket.assigns.live_action do
      :new -> create_link(socket, params)
      :edit -> update_link(socket, params)
      _ -> {:noreply, socket}
    end
  end

  def handle_event("toggle_favorite", %{"id" => link_id}, socket) do
    case Links.toggle_favorite(socket.assigns.current_scope, link_id) do
      {:ok, %Link{is_favorite: true}} ->
        {:noreply, socket |> refresh_links() |> put_flash(:info, "Link added to favorites.")}

      {:ok, %Link{is_favorite: false}} ->
        {:noreply, socket |> refresh_links() |> put_flash(:info, "Link removed from favorites.")}

      {:error, :favorite_limit_reached} ->
        {:noreply, put_flash(socket, :error, "You can only favorite up to 3 links.")}

      {:error, :archived} ->
        {:noreply, put_flash(socket, :error, "Archived links cannot be favorited.")}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Link not found.")}
    end
  end

  def handle_event("archive", %{"id" => link_id}, socket) do
    case Links.archive_link(socket.assigns.current_scope, link_id) do
      {:ok, _link} ->
        {:noreply, socket |> refresh_links() |> put_flash(:info, "Link archived.")}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Link not found.")}
    end
  end

  def handle_event("unarchive", %{"id" => link_id}, socket) do
    case Links.unarchive_link(socket.assigns.current_scope, link_id) do
      {:ok, _link} ->
        {:noreply, socket |> refresh_links() |> put_flash(:info, "Link restored.")}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Link not found.")}
    end
  end

  def handle_event("delete_archived", _params, socket) do
    with %Link{id: link_id} <- socket.assigns.deleting_link,
         {:ok, _link} <- Links.delete_archived_link(socket.assigns.current_scope, link_id) do
      {:noreply,
       socket
       |> put_flash(:info, "Link deleted.")
       |> push_patch(to: ~p"/links")}
    else
      {:error, :not_archived} ->
        {:noreply, put_flash(socket, :error, "Only archived links can be deleted.")}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Link not found.")}

      _ ->
        {:noreply, put_flash(socket, :error, "Unable to delete link.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app_shell
      flash={@flash}
      current_scope={@current_scope}
      current_path={~p"/links"}
      favorite_links={Map.get(assigns, :favorite_links, [])}
    >
      <section id="links-page" class="w-full space-y-5">
        <div class="flex flex-wrap items-center justify-between gap-4">
          <.header>
            Links
            <:subtitle>Manage your links and choose up to 3 favorites.</:subtitle>
          </.header>

          <div class="flex items-center gap-2">
            <span id="links-favorite-count" class="badge badge-outline">
              Favorites: {@favorite_count}/{Links.favorite_limit()}
            </span>
            <.link id="links-new-button" patch={~p"/links/new"} class="btn btn-primary btn-sm">
              <.icon name="hero-plus" class="size-4" /> New Link
            </.link>
          </div>
        </div>

        <div id="links-list" phx-update="stream" class="space-y-3">
          <div
            id="links-empty"
            class="hidden rounded-xl border border-dashed border-base-300 p-8 text-sm text-base-content/70 only:block"
          >
            No links yet. Add your first link.
          </div>

          <article
            :for={{dom_id, link} <- @streams.links}
            id={dom_id}
            class={[
              "rounded-xl border bg-base-100 p-4 shadow-sm transition",
              is_nil(link.archived_at) && "border-base-300",
              not is_nil(link.archived_at) && "border-base-300/70 bg-base-200/40"
            ]}
          >
            <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
              <div class="min-w-0 space-y-2">
                <div class="flex items-center gap-2">
                  <span
                    id={"link-icon-#{link.id}"}
                    class="inline-flex size-8 items-center justify-center rounded-full bg-base-200"
                  >
                    <.icon name={link.icon} class="size-4" style={"color: #{link.color}"} />
                  </span>
                  <div class="min-w-0">
                    <h3 id={"link-name-#{link.id}"} class="truncate text-sm font-semibold">
                      {link.name}
                    </h3>
                    <p id={"link-url-#{link.id}"} class="truncate text-xs text-base-content/65">
                      {link.url}
                    </p>
                  </div>
                  <span
                    :if={link.is_favorite}
                    id={"link-favorite-badge-#{link.id}"}
                    class="badge badge-error badge-outline badge-sm"
                  >
                    <.icon name="hero-heart" class="size-3" /> Favorite
                  </span>
                  <span
                    :if={not is_nil(link.archived_at)}
                    id={"link-archived-badge-#{link.id}"}
                    class="badge badge-warning badge-outline badge-sm"
                  >
                    Archived
                  </span>
                </div>

                <p
                  :if={is_binary(link.description) and link.description != ""}
                  id={"link-description-#{link.id}"}
                  class="text-sm text-base-content/75"
                >
                  {link.description}
                </p>

                <p id={"link-click-count-#{link.id}"} class="text-xs text-base-content/60">
                  Clicks: {link.click_count}
                </p>
              </div>

              <div class="flex flex-wrap items-center gap-2 sm:justify-end">
                <a
                  id={"link-open-#{link.id}"}
                  href={~p"/links/#{link.id}/open"}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="btn btn-ghost btn-sm"
                >
                  <.icon name="hero-arrow-top-right-on-square" class="size-4" /> Open
                </a>

                <button
                  :if={is_nil(link.archived_at)}
                  id={"link-toggle-favorite-#{link.id}"}
                  type="button"
                  phx-click="toggle_favorite"
                  phx-value-id={link.id}
                  class="btn btn-ghost btn-sm"
                >
                  <.icon name="hero-heart" class="size-4" />
                  {if link.is_favorite, do: "Unfavorite", else: "Favorite"}
                </button>

                <.link
                  :if={is_nil(link.archived_at)}
                  id={"link-edit-#{link.id}"}
                  patch={~p"/links/#{link.id}/edit"}
                  class="btn btn-ghost btn-sm"
                >
                  <.icon name="hero-pencil-square" class="size-4" /> Edit
                </.link>

                <button
                  :if={is_nil(link.archived_at)}
                  id={"link-archive-#{link.id}"}
                  type="button"
                  phx-click="archive"
                  phx-value-id={link.id}
                  class="btn btn-ghost btn-sm text-warning"
                >
                  <.icon name="hero-archive-box" class="size-4" /> Archive
                </button>

                <button
                  :if={not is_nil(link.archived_at)}
                  id={"link-unarchive-#{link.id}"}
                  type="button"
                  phx-click="unarchive"
                  phx-value-id={link.id}
                  class="btn btn-ghost btn-sm"
                >
                  <.icon name="hero-arrow-uturn-left" class="size-4" /> Restore
                </button>

                <.link
                  :if={not is_nil(link.archived_at)}
                  id={"link-delete-#{link.id}"}
                  patch={~p"/links/#{link.id}/delete"}
                  class="btn btn-ghost btn-sm text-error hover:bg-error/10"
                >
                  <.icon name="hero-trash" class="size-4" /> Delete
                </.link>
              </div>
            </div>
          </article>
        </div>
      </section>

      <.modal
        id="link-form-modal"
        show={@live_action in [:new, :edit]}
        on_cancel="close_modal"
        title={if @live_action == :new, do: "New Link", else: "Edit Link"}
      >
        <:subtitle>Create or update your link details.</:subtitle>

        <.form for={@form} id="link-form" phx-change="validate" phx-submit="save" class="space-y-2">
          <.input field={@form[:name]} type="text" label="Name" required />
          <.input
            field={@form[:url]}
            type="url"
            label="URL"
            placeholder="https://example.com"
            required
          />

          <.input field={@form[:icon]} type="hidden" />

          <div class="fieldset mb-2">
            <span class="label mb-1">Icon</span>
            <div id="link-icon-grid" class="grid grid-cols-5 gap-2">
              <button
                :for={icon <- Link.icon_options()}
                id={"link-icon-option-#{icon}"}
                type="button"
                phx-click="select_icon"
                phx-value-icon={icon}
                class={[
                  "inline-flex h-10 w-full items-center justify-center rounded-lg border bg-base-100 transition",
                  selected_icon(@form) == icon &&
                    "border-primary text-primary shadow-sm ring-1 ring-primary/35",
                  selected_icon(@form) != icon &&
                    "border-base-300 text-base-content/75 hover:border-base-content/45 hover:bg-base-200"
                ]}
                aria-label={icon}
              >
                <.icon name={icon} class="size-4" />
              </button>
            </div>
            <p
              :for={error <- @form[:icon].errors}
              class="mt-1.5 flex items-center gap-2 text-sm text-error"
            >
              <.icon name="hero-exclamation-circle" class="size-5" />
              {translate_error(error)}
            </p>
          </div>

          <.input field={@form[:color]} type="color" label="Icon color" required />
          <.input field={@form[:description]} type="textarea" label="Description (optional)" rows="3" />

          <div class="mt-4 flex justify-end gap-2">
            <button id="link-form-cancel" type="button" phx-click="close_modal" class="btn btn-sm">
              Cancel
            </button>
            <button
              id="link-form-submit"
              type="submit"
              phx-disable-with="Saving..."
              class={[
                "btn btn-sm btn-primary",
                "phx-submit-loading:btn-disabled phx-submit-loading:opacity-80"
              ]}
            >
              <span class="phx-submit-loading:hidden">
                {if @live_action == :new, do: "Create link", else: "Save changes"}
              </span>
              <span class="hidden items-center gap-2 phx-submit-loading:inline-flex">
                <span class="loading loading-spinner loading-xs"></span> Saving...
              </span>
            </button>
          </div>
        </.form>
      </.modal>

      <.modal
        id="link-delete-modal"
        show={@live_action == :delete and not is_nil(@deleting_link)}
        on_cancel="close_modal"
        title="Delete archived link"
        panel_class="max-w-md"
      >
        <:subtitle>This action permanently deletes the archived link.</:subtitle>
        <p :if={@deleting_link} id="link-delete-name" class="text-sm text-base-content/80">
          Link: <span class="font-semibold">{@deleting_link.name}</span>
        </p>

        <div class="mt-4 flex justify-end gap-2">
          <button id="link-delete-cancel" type="button" phx-click="close_modal" class="btn btn-sm">
            Cancel
          </button>
          <button
            id="link-delete-confirm"
            type="button"
            phx-click="delete_archived"
            class="btn btn-sm btn-error"
          >
            Delete link
          </button>
        </div>
      </.modal>
    </Layouts.app_shell>
    """
  end

  defp create_link(socket, params) do
    case Links.create_link(socket.assigns.current_scope, params) do
      {:ok, _link} ->
        {:noreply, socket |> put_flash(:info, "Link created.") |> push_patch(to: ~p"/links")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  defp update_link(socket, params) do
    case Links.update_link(socket.assigns.current_scope, socket.assigns.editing_link.id, params) do
      {:ok, _link} ->
        {:noreply, socket |> put_flash(:info, "Link updated.") |> push_patch(to: ~p"/links")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(Map.put(changeset, :action, :insert)))}

      {:error, :not_found} ->
        {:noreply, socket |> put_flash(:error, "Link not found.") |> push_patch(to: ~p"/links")}
    end
  end

  defp apply_live_action(socket, :index, _params) do
    socket
    |> assign(:editing_link, nil)
    |> assign(:deleting_link, nil)
    |> assign(:form_params, %{})
    |> assign(:form, link_form(%Link{}))
  end

  defp apply_live_action(socket, :new, _params) do
    socket
    |> assign(:editing_link, nil)
    |> assign(:deleting_link, nil)
    |> assign(:form_params, %{})
    |> assign(:form, link_form(%Link{}))
  end

  defp apply_live_action(socket, :edit, %{"id" => link_id}) do
    case Links.get_owned_link(socket.assigns.current_scope, link_id) do
      %Link{} = link ->
        socket
        |> assign(:editing_link, link)
        |> assign(:deleting_link, nil)
        |> assign(:form_params, %{})
        |> assign(:form, link_form(link))

      nil ->
        socket
        |> put_flash(:error, "Link not found.")
        |> push_patch(to: ~p"/links")
    end
  end

  defp apply_live_action(socket, :delete, %{"id" => link_id}) do
    case Links.get_owned_link(socket.assigns.current_scope, link_id) do
      %Link{archived_at: nil} ->
        socket
        |> put_flash(:error, "Archive the link before deleting it.")
        |> push_patch(to: ~p"/links")

      %Link{} = link ->
        socket
        |> assign(:editing_link, nil)
        |> assign(:deleting_link, link)
        |> assign(:form_params, %{})

      nil ->
        socket
        |> put_flash(:error, "Link not found.")
        |> push_patch(to: ~p"/links")
    end
  end

  defp refresh_links(socket) do
    links = Links.list_links(socket.assigns.current_scope, include_archived: true)

    socket
    |> stream(:links, links, reset: true)
    |> assign(:favorite_count, Links.count_favorites(socket.assigns.current_scope))
  end

  defp link_form(%Link{} = link) do
    link
    |> Links.change_link()
    |> to_form()
  end

  defp selected_icon(form) do
    cond do
      is_map(form.params) and form.params != %{} ->
        Map.get(form.params, "icon")

      true ->
        form.data.icon
    end
  end
end
