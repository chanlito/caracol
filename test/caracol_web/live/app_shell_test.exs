defmodule CaracolWeb.AppShellTest do
  use CaracolWeb.ConnCase, async: true

  import Caracol.AccountsFixtures
  import Phoenix.LiveViewTest

  describe "authenticated app routes" do
    test "redirect unauthenticated users from live routes", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/home")
      assert {:redirect, %{to: path}} = redirect
      assert path == ~p"/users/log-in"

      assert {:error, redirect} = live(conn, ~p"/playground")
      assert {:redirect, %{to: path}} = redirect
      assert path == ~p"/users/log-in"

      assert {:error, redirect} = live(conn, ~p"/users/settings")
      assert {:redirect, %{to: path}} = redirect
      assert path == ~p"/users/log-in"
    end

    test "renders shell and nav on /home for authenticated users", %{conn: conn} do
      user = user_fixture()

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/home")

      assert has_element?(view, "#app-shell-sidebar")
      assert has_element?(view, "#app-shell-mobile-toggle")
      assert has_element?(view, "#app-sidebar-desktop-toggle")
      assert has_element?(view, "#app-nav-home")
      assert has_element?(view, "#app-nav-playground")
      assert has_element?(view, "#app-nav-settings")
      assert has_element?(view, "#app-sidebar-account")
      assert has_element?(view, "#app-sidebar-user-menu")
      assert has_element?(view, "#app-user-settings")
      assert has_element?(view, "#app-theme-dropdown")
      assert has_element?(view, "#app-user-logout")
      assert has_element?(view, "#home-page")

      html = render(view)
      assert html =~ "hero-home"
      assert html =~ "hero-beaker"
      assert html =~ "hero-cog-6-tooth"
      assert html =~ user.email
    end

    test "renders placeholder page on /playground for authenticated users", %{conn: conn} do
      user = user_fixture()

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/playground")

      assert has_element?(view, "#playground-page")
      assert has_element?(view, "#app-shell-sidebar")
      assert has_element?(view, "#app-nav-playground")
    end
  end

  describe "/users redirect" do
    test "redirects unauthenticated users to log in", %{conn: conn} do
      conn = get(conn, ~p"/users")
      assert redirected_to(conn) == ~p"/users/log-in"
    end

    test "redirects authenticated users to settings", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/users")

      assert redirected_to(conn) == ~p"/users/settings"
    end
  end
end
