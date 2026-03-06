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
     |> assign(:favorite_count, 0)
     |> assign(:total_count, 0)
     |> assign(:archived_count, 0)
     |> assign(:active_count, 0)
     |> refresh_links()}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket = apply_live_action(socket, socket.assigns.live_action, params)

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
       |> refresh_links()
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
      <section id="links-page" class="relative isolate w-full space-y-6 pb-2">
        <div
          aria-hidden="true"
          class="pointer-events-none absolute left-2 top-0 h-52 w-52 rounded-full bg-primary/15 blur-3xl dark:bg-primary/10"
        >
        </div>
        <div
          aria-hidden="true"
          class="pointer-events-none absolute right-2 top-8 h-60 w-60 rounded-full bg-secondary/15 blur-3xl dark:bg-secondary/10"
        >
        </div>

        <header class="relative overflow-hidden rounded-3xl border border-base-300/70 bg-base-100/90 p-5 dark:border-base-300/55 dark:bg-base-200/80 sm:p-7">
          <div
            aria-hidden="true"
            class="pointer-events-none absolute inset-0 bg-[radial-gradient(130%_100%_at_0%_0%,color-mix(in_oklab,var(--color-primary)_15%,transparent)_0%,transparent_55%)] dark:bg-[radial-gradient(130%_100%_at_0%_0%,color-mix(in_oklab,var(--color-primary)_24%,transparent)_0%,transparent_65%)]"
          >
          </div>
          <div class="relative space-y-5">
            <div class="flex flex-wrap items-start justify-between gap-4">
              <div>
                <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
                  Personal Knowledge Deck
                </p>
                <h1 class="mt-1 text-3xl font-semibold tracking-tight text-base-content">Links</h1>
                <p class="mt-2 max-w-2xl text-sm text-base-content/70">
                  Capture references fast, spotlight the three links you need most, and keep old
                  material archived without losing context.
                </p>
              </div>

              <.link
                id="links-new-button"
                patch={~p"/links/new"}
                class="inline-flex h-10 cursor-pointer items-center gap-2 rounded-xl border border-primary/35 bg-primary/10 px-4 text-sm font-semibold text-primary transition duration-200 ease-out hover:-translate-y-0.5 hover:bg-primary/15 hover:shadow-md hover:shadow-primary/20 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary dark:border-primary/45 dark:bg-primary/20 dark:text-primary-content dark:hover:bg-primary/28 dark:hover:shadow-primary/30"
              >
                <.icon name="hero-plus" class="size-4" /> Add Link
              </.link>
            </div>

            <div class="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
              <div class="rounded-2xl border border-base-300/70 bg-base-100/80 px-4 py-3">
                <p class="text-[0.68rem] font-semibold uppercase tracking-[0.14em] text-base-content/60">
                  Total
                </p>
                <p class="mt-1 text-2xl font-semibold tracking-tight text-base-content">
                  {@total_count}
                </p>
              </div>
              <div class="rounded-2xl border border-base-300/70 bg-base-100/80 px-4 py-3">
                <p class="text-[0.68rem] font-semibold uppercase tracking-[0.14em] text-base-content/60">
                  Active
                </p>
                <p class="mt-1 text-2xl font-semibold tracking-tight text-base-content">
                  {@active_count}
                </p>
              </div>
              <div class="rounded-2xl border border-base-300/70 bg-base-100/80 px-4 py-3">
                <p class="text-[0.68rem] font-semibold uppercase tracking-[0.14em] text-base-content/60">
                  Archived
                </p>
                <p class="mt-1 text-2xl font-semibold tracking-tight text-base-content">
                  {@archived_count}
                </p>
              </div>
              <div
                id="links-favorite-count"
                class="rounded-2xl border border-error/30 bg-error/8 px-4 py-3 dark:border-error/40 dark:bg-error/16"
              >
                <p class="text-[0.68rem] font-semibold uppercase tracking-[0.14em] text-base-content/65">
                  Favorites
                </p>
                <p class="mt-1 flex items-center gap-2 text-2xl font-semibold tracking-tight text-base-content">
                  <.icon name="hero-heart" class="size-5 text-error" />
                  <span>{@favorite_count}/{Links.favorite_limit()}</span>
                </p>
              </div>
            </div>
          </div>
        </header>

        <div id="links-list" phx-update="stream" class="space-y-3">
          <div
            id="links-empty"
            class="links-empty hidden rounded-3xl border border-dashed border-base-300 bg-base-100/80 p-8 text-base-content/70 only:block"
          >
            <div class="mx-auto max-w-lg space-y-3 text-center">
              <p class="text-sm font-medium uppercase tracking-[0.14em] text-base-content/55">
                Start Your Collection
              </p>
              <p class="text-balance text-base">
                No links yet. Add your first link and pin favorites so your most-used references are
                always one click away.
              </p>
              <.link
                patch={~p"/links/new"}
                class="inline-flex h-10 cursor-pointer items-center gap-2 rounded-xl border border-primary/35 bg-primary/10 px-4 text-sm font-semibold text-primary transition duration-200 ease-out hover:-translate-y-0.5 hover:bg-primary/15 dark:border-primary/45 dark:bg-primary/20 dark:text-primary-content dark:hover:bg-primary/28"
              >
                <.icon name="hero-plus" class="size-4" /> Create first link
              </.link>
            </div>
          </div>

          <article
            :for={{dom_id, link} <- @streams.links}
            id={dom_id}
            class={[
              "links-card group relative overflow-hidden rounded-2xl border bg-base-100/95 p-4 transition-colors duration-200 ease-out hover:border-base-content/20 dark:hover:border-base-content/25",
              is_nil(link.archived_at) && "border-base-300/80",
              not is_nil(link.archived_at) &&
                "border-warning/30 bg-base-200/55 dark:border-warning/40 dark:bg-base-200/75"
            ]}
          >
            <div
              aria-hidden="true"
              class="pointer-events-none absolute inset-y-0 right-0 w-24 bg-gradient-to-l from-primary/10 to-transparent opacity-0 transition duration-300 ease-out group-hover:opacity-100 dark:from-primary/20"
            >
            </div>

            <div class="relative flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
              <div class="min-w-0 flex-1">
                <div class="flex min-w-0 items-start gap-3">
                  <span
                    id={"link-icon-#{link.id}"}
                    class="inline-flex size-11 shrink-0 items-center justify-center rounded-2xl border border-base-300/70"
                    style={"background-color: color-mix(in oklab, #{link.color} 18%, var(--color-base-100)); color: #{link.color}"}
                  >
                    <.icon name={link.icon} class="size-5" />
                  </span>

                  <div class="min-w-0 flex-1">
                    <div class="flex flex-wrap items-center gap-2">
                      <h3
                        id={"link-name-#{link.id}"}
                        class="truncate text-base font-semibold tracking-tight text-base-content"
                      >
                        {link.name}
                      </h3>

                      <span
                        :if={link.is_favorite}
                        id={"link-favorite-badge-#{link.id}"}
                        class="inline-flex items-center gap-1 rounded-full border border-error/35 bg-error/10 px-2 py-0.5 text-xs font-medium text-error"
                      >
                        <.icon name="hero-heart" class="size-3.5" /> Favorite
                      </span>

                      <span
                        :if={not is_nil(link.archived_at)}
                        id={"link-archived-badge-#{link.id}"}
                        class="inline-flex items-center gap-1 rounded-full border border-warning/35 bg-warning/10 px-2 py-0.5 text-xs font-medium text-warning-content dark:border-warning/45 dark:bg-warning/18 dark:text-warning"
                      >
                        <.icon name="hero-archive-box" class="size-3.5" /> Archived
                      </span>
                    </div>

                    <p
                      id={"link-url-#{link.id}"}
                      class="mt-1 truncate text-sm text-base-content/65 transition-colors duration-200 group-hover:text-base-content/80"
                    >
                      {link.url}
                    </p>

                    <p
                      :if={is_binary(link.description) and link.description != ""}
                      id={"link-description-#{link.id}"}
                      class="mt-2 line-clamp-2 text-sm text-base-content/75"
                    >
                      {link.description}
                    </p>

                    <div class="mt-3 flex flex-wrap items-center gap-3 text-xs text-base-content/65">
                      <p id={"link-click-count-#{link.id}"} class="inline-flex items-center gap-1.5">
                        <.icon name="hero-cursor-arrow-rays" class="size-3.5" />
                        Clicks: {link.click_count}
                      </p>
                      <p class="inline-flex items-center gap-1.5">
                        <.icon name="hero-clock" class="size-3.5" />
                        Updated {Calendar.strftime(link.updated_at, "%b %-d, %Y")}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div class="flex flex-wrap items-center gap-2 lg:justify-end">
                <a
                  id={"link-open-#{link.id}"}
                  href={~p"/links/#{link.id}/open"}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="inline-flex h-9 cursor-pointer items-center gap-1.5 rounded-xl border border-primary/35 bg-primary/10 px-3 text-sm font-medium text-primary transition duration-200 ease-out hover:-translate-y-0.5 hover:bg-primary/15 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary dark:border-primary/45 dark:bg-primary/20 dark:text-primary-content dark:hover:bg-primary/28"
                >
                  <.icon name="hero-arrow-top-right-on-square" class="size-4" /> Open
                </a>

                <button
                  :if={is_nil(link.archived_at)}
                  id={"link-toggle-favorite-#{link.id}"}
                  type="button"
                  phx-click="toggle_favorite"
                  phx-value-id={link.id}
                  class="inline-flex h-9 cursor-pointer items-center gap-1.5 rounded-xl border border-base-300 bg-base-100 px-3 text-sm text-base-content/80 transition duration-200 ease-out hover:bg-base-200 hover:text-base-content"
                >
                  <.icon name="hero-heart" class="size-4" />
                  {if link.is_favorite, do: "Unfavorite", else: "Favorite"}
                </button>

                <.link
                  :if={is_nil(link.archived_at)}
                  id={"link-edit-#{link.id}"}
                  patch={~p"/links/#{link.id}/edit"}
                  class="inline-flex h-9 cursor-pointer items-center gap-1.5 rounded-xl border border-base-300 bg-base-100 px-3 text-sm text-base-content/80 transition duration-200 ease-out hover:bg-base-200 hover:text-base-content"
                >
                  <.icon name="hero-pencil-square" class="size-4" /> Edit
                </.link>

                <button
                  :if={is_nil(link.archived_at)}
                  id={"link-archive-#{link.id}"}
                  type="button"
                  phx-click="archive"
                  phx-value-id={link.id}
                  class="inline-flex h-9 cursor-pointer items-center gap-1.5 rounded-xl border border-warning/35 bg-warning/10 px-3 text-sm font-medium text-warning-content transition duration-200 ease-out hover:bg-warning/15 dark:border-warning/45 dark:bg-warning/18 dark:text-warning dark:hover:bg-warning/24"
                >
                  <.icon name="hero-archive-box" class="size-4" /> Archive
                </button>

                <button
                  :if={not is_nil(link.archived_at)}
                  id={"link-unarchive-#{link.id}"}
                  type="button"
                  phx-click="unarchive"
                  phx-value-id={link.id}
                  class="inline-flex h-9 cursor-pointer items-center gap-1.5 rounded-xl border border-base-300 bg-base-100 px-3 text-sm text-base-content/80 transition duration-200 ease-out hover:bg-base-200 hover:text-base-content"
                >
                  <.icon name="hero-arrow-uturn-left" class="size-4" /> Restore
                </button>

                <.link
                  :if={not is_nil(link.archived_at)}
                  id={"link-delete-#{link.id}"}
                  patch={~p"/links/#{link.id}/delete"}
                  class="inline-flex h-9 cursor-pointer items-center gap-1.5 rounded-xl border border-error/35 bg-error/10 px-3 text-sm font-medium text-error transition duration-200 ease-out hover:bg-error/15"
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
        panel_class="max-w-2xl"
      >
        <:subtitle>
          Build a clean link card with icon, color, and notes you can scan quickly.
        </:subtitle>

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
            <div id="link-icon-grid" class="grid grid-cols-5 gap-2 sm:grid-cols-10">
              <button
                :for={icon <- Link.icon_options()}
                id={"link-icon-option-#{icon}"}
                type="button"
                phx-click="select_icon"
                phx-value-icon={icon}
                class={[
                  "inline-flex h-10 w-full cursor-pointer items-center justify-center rounded-xl border bg-base-100 transition duration-200 ease-out hover:-translate-y-0.5",
                  selected_icon(@form) == icon &&
                    "border-primary text-primary shadow-sm ring-2 ring-primary/30",
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

          <div class="mt-2 flex justify-end gap-2">
            <button
              id="link-form-cancel"
              type="button"
              phx-click="close_modal"
              class="inline-flex h-10 cursor-pointer items-center rounded-xl border border-base-300 px-4 text-sm font-medium text-base-content/80 transition duration-200 ease-out hover:bg-base-200"
            >
              Cancel
            </button>
            <button
              id="link-form-submit"
              type="submit"
              phx-disable-with="Saving..."
              class={[
                "inline-flex h-10 cursor-pointer items-center rounded-xl border border-primary/35 bg-primary/10 px-4 text-sm font-semibold text-primary transition duration-200 ease-out hover:-translate-y-0.5 hover:bg-primary/15",
                "dark:border-primary/45 dark:bg-primary/20 dark:text-primary-content dark:hover:bg-primary/28",
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
        <:subtitle>
          This action permanently removes the link from your collection and cannot be undone.
        </:subtitle>
        <p :if={@deleting_link} id="link-delete-name" class="mt-1 text-sm text-base-content/80">
          Link: <span class="font-semibold">{@deleting_link.name}</span>
        </p>

        <div class="mt-5 flex justify-end gap-2">
          <button
            id="link-delete-cancel"
            type="button"
            phx-click="close_modal"
            class="inline-flex h-10 cursor-pointer items-center rounded-xl border border-base-300 px-4 text-sm font-medium text-base-content/80 transition duration-200 ease-out hover:bg-base-200"
          >
            Cancel
          </button>
          <button
            id="link-delete-confirm"
            type="button"
            phx-click="delete_archived"
            class="inline-flex h-10 cursor-pointer items-center rounded-xl border border-error/40 bg-error/10 px-4 text-sm font-semibold text-error transition duration-200 ease-out hover:bg-error/15"
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
        {:noreply,
         socket
         |> refresh_links()
         |> put_flash(:info, "Link created.")
         |> push_patch(to: ~p"/links")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  defp update_link(socket, params) do
    case Links.update_link(socket.assigns.current_scope, socket.assigns.editing_link.id, params) do
      {:ok, _link} ->
        {:noreply,
         socket
         |> refresh_links()
         |> put_flash(:info, "Link updated.")
         |> push_patch(to: ~p"/links")}

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
    total_count = length(links)
    archived_count = Enum.count(links, &(not is_nil(&1.archived_at)))
    active_count = total_count - archived_count

    socket
    |> stream(:links, links, reset: true)
    |> assign(:favorite_count, Links.count_favorites(socket.assigns.current_scope))
    |> assign(:total_count, total_count)
    |> assign(:archived_count, archived_count)
    |> assign(:active_count, active_count)
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
