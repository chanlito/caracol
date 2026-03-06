defmodule CaracolWeb.LinkRedirectControllerTest do
  use CaracolWeb.ConnCase, async: true

  import Caracol.AccountsFixtures
  import Caracol.LinksFixtures

  alias Caracol.Accounts.Scope
  alias Caracol.Links

  test "redirects authenticated users and increments click count", %{conn: conn} do
    user = user_fixture()
    scope = Scope.for_user(user)
    link = link_fixture(scope, %{url: "https://example.com/open"})

    conn =
      conn
      |> log_in_user(user)
      |> get(~p"/links/#{link.id}/open")

    assert redirected_to(conn) == "https://example.com/open"
    {:ok, updated_link} = Links.open_link(scope, link.id)
    assert updated_link.click_count == 2
  end

  test "redirects unauthenticated users to login", %{conn: conn} do
    scope = user_scope_fixture()
    link = link_fixture(scope)

    conn = get(conn, ~p"/links/#{link.id}/open")
    assert redirected_to(conn) == ~p"/users/log-in"
  end

  test "shows error when link is missing", %{conn: conn} do
    user = user_fixture()

    conn =
      conn
      |> log_in_user(user)
      |> get(~p"/links/#{Ecto.UUID.generate()}/open")

    assert redirected_to(conn) == ~p"/links"
    assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Link not found."
  end
end
