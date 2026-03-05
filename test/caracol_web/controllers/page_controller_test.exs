defmodule CaracolWeb.PageControllerTest do
  use CaracolWeb.ConnCase

  test "GET / renders the public landing page", %{conn: conn} do
    conn = get(conn, ~p"/")
    response = html_response(conn, 200)

    assert response =~ ~s(id="landing-navbar")
    assert response =~ ~s(id="landing-hero")
    assert response =~ ~s(id="landing-companies")
    assert response =~ ~s(id="landing-testimonials")
    assert response =~ ~s(id="landing-technology")
    assert response =~ ~s(id="landing-cta")
    assert response =~ ~s(id="home-theme-dropdown")
    assert response =~ "Used by companies"
    assert response =~ "Testimonials"
    assert response =~ "Technology"
    assert response =~ "hero-user-plus"
    assert response =~ "Register"
    assert response =~ "Log in"
    refute response =~ "Settings"
    refute response =~ "Log out"
  end

  test "GET / renders authenticated actions for signed-in users", %{conn: conn} do
    user = Caracol.AccountsFixtures.user_fixture()

    conn =
      conn
      |> log_in_user(user)
      |> get(~p"/")

    response = html_response(conn, 200)

    assert response =~ ~s(id="home-theme-dropdown")
    assert response =~ user.email
    assert response =~ "Log out"
    refute response =~ "Register now"
  end
end
