defmodule CaracolWeb.LinkRedirectController do
  use CaracolWeb, :controller

  alias Caracol.Links

  def open(conn, %{"id" => link_id}) do
    case Links.open_link(conn.assigns.current_scope, link_id) do
      {:ok, link} ->
        redirect(conn, external: link.url)

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Link not found.")
        |> redirect(to: ~p"/links")
    end
  end
end
