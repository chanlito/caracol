defmodule CaracolWeb.UserLive.SessionsTest do
  use CaracolWeb.ConnCase, async: true

  import Ecto.Query
  import Caracol.AccountsFixtures
  import Phoenix.LiveViewTest

  alias Caracol.Accounts.UserToken
  alias Caracol.Repo

  describe "Sessions page" do
    test "renders sessions list and active settings tab", %{conn: conn} do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/sessions")

      assert has_element?(lv, "#settings-subnav")
      assert has_element?(lv, "#settings-tab-sessions[aria-current='page']")
      assert has_element?(lv, "#sessions-list")
      assert has_element?(lv, "[id^='session-']")
    end

    test "renders empty state after refresh when no active sessions remain", %{conn: conn} do
      user = user_fixture()

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      Repo.delete_all(
        from(t in UserToken, where: t.user_id == ^user.id and t.context == "session")
      )

      lv
      |> element("#sessions-refresh")
      |> render_click()

      assert has_element?(lv, "#sessions-empty")
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/sessions")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end
