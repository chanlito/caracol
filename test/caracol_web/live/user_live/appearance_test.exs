defmodule CaracolWeb.UserLive.AppearanceTest do
  use CaracolWeb.ConnCase, async: true

  import Caracol.AccountsFixtures
  import Phoenix.LiveViewTest

  describe "Appearance page" do
    test "renders page and active settings tab", %{conn: conn} do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/appearance")

      assert has_element?(lv, "#settings-subnav")
      assert has_element?(lv, "#settings-tab-appearance[aria-current='page']")
      assert has_element?(lv, "#appearance-settings")
      assert has_element?(lv, "#appearance-theme-options")
      assert has_element?(lv, "#appearance-theme-system")
      assert has_element?(lv, "#appearance-theme-light")
      assert has_element?(lv, "#appearance-theme-dark")
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/appearance")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end
