defmodule CaracolWeb.GlobalFavorites do
  @moduledoc false

  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [attach_hook: 4, connected?: 1]

  alias Caracol.Links

  def on_mount(:global_favorites, _params, _session, socket) do
    if connected?(socket) do
      Links.subscribe_global_favorites()
    end

    socket =
      socket
      |> assign(:favorite_links, Links.list_global_favorite_links())
      |> attach_hook(:global_favorites, :handle_info, &handle_info/2)

    {:cont, socket}
  end

  defp handle_info(:favorites_changed, socket) do
    {:halt, assign(socket, :favorite_links, Links.list_global_favorite_links())}
  end

  defp handle_info(_message, socket), do: {:cont, socket}
end
