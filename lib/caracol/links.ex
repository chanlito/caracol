defmodule Caracol.Links do
  @moduledoc """
  The Links context.
  """

  import Ecto.Query, warn: false

  alias Caracol.Accounts.{Scope, User}
  alias Caracol.Links.Link
  alias Caracol.Repo

  @favorites_topic "links:favorites"
  @favorite_limit 3

  def subscribe_global_favorites do
    Phoenix.PubSub.subscribe(Caracol.PubSub, @favorites_topic)
  end

  def subscribe_user_links(%Scope{user: %User{id: user_id}}) when is_binary(user_id) do
    Phoenix.PubSub.subscribe(Caracol.PubSub, user_links_topic(user_id))
  end

  def subscribe_user_links(_scope), do: :ok

  def list_links(scope, opts \\ [])

  def list_links(%Scope{user: %User{id: user_id}}, opts) do
    include_archived = Keyword.get(opts, :include_archived, true)

    Link
    |> where([link], link.user_id == ^user_id)
    |> maybe_filter_archived(include_archived)
    |> order_by([link],
      asc: fragment("CASE WHEN ? IS NULL THEN 0 ELSE 1 END", link.archived_at),
      asc: link.name
    )
    |> Repo.all()
  end

  def list_links(_scope, _opts), do: []

  def list_global_favorite_links do
    Link
    |> where([link], link.is_favorite and is_nil(link.archived_at))
    |> order_by([link], asc: link.name)
    |> Repo.all()
  end

  def count_favorites(scope)

  def count_favorites(%Scope{user: %User{id: user_id}}) do
    Link
    |> where([link], link.user_id == ^user_id and link.is_favorite and is_nil(link.archived_at))
    |> select([link], count(link.id))
    |> Repo.one()
  end

  def count_favorites(_scope), do: 0

  def get_owned_link(scope, link_id)

  def get_owned_link(%Scope{user: %User{id: user_id}}, link_id) when is_binary(link_id) do
    Repo.get_by(Link, id: link_id, user_id: user_id)
  end

  def get_owned_link(_scope, _link_id), do: nil

  def change_link(%Link{} = link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end

  def create_link(scope, attrs)

  def create_link(%Scope{user: %User{id: user_id}}, attrs) when is_map(attrs) do
    %Link{user_id: user_id}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  def create_link(_scope, _attrs), do: {:error, :unauthorized}

  def update_link(scope, link_id, attrs)

  def update_link(%Scope{} = scope, link_id, attrs) when is_binary(link_id) and is_map(attrs) do
    with %Link{} = link <- get_owned_link(scope, link_id),
         {:ok, updated_link} <- link |> Link.changeset(attrs) |> Repo.update() do
      maybe_broadcast_favorite_visibility(link, updated_link)
      {:ok, updated_link}
    else
      nil -> {:error, :not_found}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def update_link(_scope, _link_id, _attrs), do: {:error, :unauthorized}

  def archive_link(scope, link_id)

  def archive_link(%Scope{} = scope, link_id) when is_binary(link_id) do
    with %Link{} = link <- get_owned_link(scope, link_id),
         {:ok, archived_link} <- do_archive_link(link) do
      maybe_broadcast_favorites(link, archived_link)
      {:ok, archived_link}
    else
      nil -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  def archive_link(_scope, _link_id), do: {:error, :unauthorized}

  def unarchive_link(scope, link_id)

  def unarchive_link(%Scope{} = scope, link_id) when is_binary(link_id) do
    with %Link{} = link <- get_owned_link(scope, link_id),
         {:ok, unarchived_link} <- do_unarchive_link(link) do
      maybe_broadcast_favorites(link, unarchived_link)
      {:ok, unarchived_link}
    else
      nil -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  def unarchive_link(_scope, _link_id), do: {:error, :unauthorized}

  def delete_archived_link(scope, link_id)

  def delete_archived_link(%Scope{} = scope, link_id) when is_binary(link_id) do
    with %Link{} = link <- get_owned_link(scope, link_id),
         true <- not is_nil(link.archived_at),
         {:ok, deleted_link} <- Repo.delete(link) do
      maybe_broadcast_favorites(link, deleted_link)
      {:ok, deleted_link}
    else
      nil -> {:error, :not_found}
      false -> {:error, :not_archived}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_archived_link(_scope, _link_id), do: {:error, :unauthorized}

  def toggle_favorite(scope, link_id)

  def toggle_favorite(%Scope{} = scope, link_id) when is_binary(link_id) do
    with %Link{} = link <- get_owned_link(scope, link_id),
         true <- is_nil(link.archived_at),
         {:ok, toggled_link} <- do_toggle_favorite(scope, link) do
      maybe_broadcast_favorites(link, toggled_link)
      {:ok, toggled_link}
    else
      nil -> {:error, :not_found}
      false -> {:error, :archived}
      {:error, reason} -> {:error, reason}
    end
  end

  def toggle_favorite(_scope, _link_id), do: {:error, :unauthorized}

  def open_link(scope, link_id)

  def open_link(%Scope{user: %User{}}, link_id) when is_binary(link_id) do
    case Repo.get(Link, link_id) do
      %Link{archived_at: nil} = link ->
        with {:ok, opened_link} <-
               link
               |> Ecto.Changeset.change(click_count: link.click_count + 1)
               |> Repo.update() do
          broadcast_user_links_changed(opened_link.user_id)
          {:ok, opened_link}
        end

      _ ->
        {:error, :not_found}
    end
  end

  def open_link(_scope, _link_id), do: {:error, :unauthorized}

  def favorite_limit, do: @favorite_limit

  defp do_archive_link(%Link{} = link) do
    link
    |> Ecto.Changeset.change(archived_at: DateTime.utc_now(:second), is_favorite: false)
    |> Repo.update()
  end

  defp do_unarchive_link(%Link{} = link) do
    link
    |> Ecto.Changeset.change(archived_at: nil)
    |> Repo.update()
  end

  defp do_toggle_favorite(_scope, %Link{is_favorite: true} = link) do
    link
    |> Ecto.Changeset.change(is_favorite: false)
    |> Repo.update()
  end

  defp do_toggle_favorite(scope, %Link{is_favorite: false} = link) do
    if count_favorites(scope) >= @favorite_limit do
      {:error, :favorite_limit_reached}
    else
      link
      |> Ecto.Changeset.change(is_favorite: true)
      |> Repo.update()
    end
  end

  defp maybe_filter_archived(query, true), do: query
  defp maybe_filter_archived(query, false), do: where(query, [link], is_nil(link.archived_at))

  defp maybe_broadcast_favorite_visibility(%Link{} = link, %Link{} = updated_link) do
    if favorite_visibility_changed?(link, updated_link) do
      broadcast_favorites_changed()
    end
  end

  defp favorite_visibility_changed?(previous, current) do
    previous.name != current.name or previous.icon != current.icon or
      previous.color != current.color or previous.is_favorite != current.is_favorite or
      is_nil(previous.archived_at) != is_nil(current.archived_at)
  end

  defp maybe_broadcast_favorites(previous, current) do
    if previous.is_favorite or current.is_favorite do
      broadcast_favorites_changed()
    end
  end

  defp broadcast_favorites_changed do
    Phoenix.PubSub.broadcast(Caracol.PubSub, @favorites_topic, :favorites_changed)
  end

  defp broadcast_user_links_changed(user_id) when is_binary(user_id) do
    Phoenix.PubSub.broadcast(Caracol.PubSub, user_links_topic(user_id), :links_changed)
  end

  defp user_links_topic(user_id), do: "links:user:#{user_id}"
end
