defmodule CaracolWeb.UserLive.SessionsTest do
  use CaracolWeb.ConnCase, async: true

  import Ecto.Query
  import Caracol.AccountsFixtures
  import Phoenix.LiveViewTest

  alias Caracol.Accounts
  alias Caracol.Accounts.UserToken
  alias Caracol.Repo

  describe "Sessions page" do
    test "renders sessions list, metadata, and active settings tab", %{conn: conn} do
      user = user_fixture()

      token =
        Accounts.generate_user_session_token(user, %{
          user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) Chrome/124.0 Safari/537.36",
          ip_address: "198.51.100.40"
        })

      session = Repo.get_by!(UserToken, token: token)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      assert has_element?(lv, "#settings-subnav")
      assert has_element?(lv, "#settings-tab-sessions[aria-current='page']")
      assert has_element?(lv, "#sessions-list")
      assert has_element?(lv, "#sessions-table")
      assert has_element?(lv, "[id^='session-']")
      assert has_element?(lv, "#session-login-#{session.id}")
      assert has_element?(lv, "#session-browser-#{session.id}")
      assert has_element?(lv, "#session-device-os-#{session.id}")
      assert has_element?(lv, "#session-ip-#{session.id}", "198.51.100.40")
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

    test "toggle expired shows and hides expired sessions", %{conn: conn} do
      user = user_fixture()
      active_token = Accounts.generate_user_session_token(user)
      expired_token = Accounts.generate_user_session_token(user)
      offset_user_token(expired_token, -20, :day)

      %UserToken{id: active_id} = Repo.get_by!(UserToken, token: active_token)
      %UserToken{id: expired_id} = Repo.get_by!(UserToken, token: expired_token)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      assert has_element?(lv, "#session-#{active_id}")
      refute has_element?(lv, "#session-#{expired_id}")
      assert has_element?(lv, "#sessions-toggle-expired", "Show expired")

      lv
      |> element("#sessions-toggle-expired")
      |> render_click()

      assert has_element?(lv, "#sessions-toggle-expired", "Hide expired")
      assert has_element?(lv, "#session-#{expired_id}")
      assert has_element?(lv, "#session-expired-#{expired_id}", "Expired")

      lv
      |> element("#sessions-toggle-expired")
      |> render_click()

      assert has_element?(lv, "#sessions-toggle-expired", "Show expired")
      refute has_element?(lv, "#session-#{expired_id}")
    end

    test "renders first page with at most 10 rows and pagination metadata", %{conn: conn} do
      user = user_fixture()

      for _ <- 1..15 do
        Accounts.generate_user_session_token(user)
      end

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      session_ids = session_ids_for_user(user)
      first_page_ids = Enum.take(session_ids, 10)
      second_page_first_id = Enum.at(session_ids, 10)
      total_pages = div(length(session_ids) + 9, 10)

      assert has_element?(lv, "#sessions-pagination")
      assert has_element?(lv, "#sessions-page-label", "Page 1 of #{total_pages}")
      assert has_element?(lv, "#sessions-total-count", "#{length(session_ids)} total sessions")
      assert has_element?(lv, "#sessions-page-prev[disabled]")
      refute has_element?(lv, "#sessions-page-next[disabled]")

      for session_id <- first_page_ids do
        assert has_element?(lv, "#session-#{session_id}")
      end

      refute has_element?(lv, "#session-#{second_page_first_id}")
    end

    test "prev and next pagination controls update URL and rows", %{conn: conn} do
      user = user_fixture()

      for _ <- 1..12 do
        Accounts.generate_user_session_token(user)
      end

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      session_ids = session_ids_for_user(user)
      page_1_id = hd(session_ids)
      page_2_id = Enum.at(session_ids, 10)

      assert has_element?(lv, "#session-#{page_1_id}")
      refute has_element?(lv, "#session-#{page_2_id}")

      lv
      |> element("#sessions-page-next")
      |> render_click()

      assert_patch(lv, ~p"/users/sessions?page=2")
      assert has_element?(lv, "#session-#{page_2_id}")
      refute has_element?(lv, "#session-#{page_1_id}")

      lv
      |> element("#sessions-page-prev")
      |> render_click()

      assert_patch(lv, ~p"/users/sessions")
      assert has_element?(lv, "#session-#{page_1_id}")
      refute has_element?(lv, "#session-#{page_2_id}")
    end

    test "realtime session create and revoke keeps current page when still valid", %{conn: conn} do
      user = user_fixture()

      for _ <- 1..11 do
        Accounts.generate_user_session_token(user)
      end

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      lv
      |> element("#sessions-page-next")
      |> render_click()

      assert_patch(lv, ~p"/users/sessions?page=2")

      _new_session_token = Accounts.generate_user_session_token(user)
      session_ids = session_ids_for_user(user)
      revoke_session_id = Enum.at(session_ids, 1)

      assert {:ok, _revoked} =
               Accounts.revoke_user_session(user_scope_fixture(user), revoke_session_id)

      _ = :sys.get_state(lv.pid)

      expected_page_2_ids = user |> session_ids_for_user() |> Enum.drop(10)
      assert expected_page_2_ids != []
      assert has_element?(lv, "#sessions-page-label", "Page 2 of 2")
      assert has_element?(lv, "#session-#{hd(expected_page_2_ids)}")
    end

    test "realtime revoke clamps back to last available page", %{conn: conn} do
      user = user_fixture()

      for _ <- 1..10 do
        Accounts.generate_user_session_token(user)
      end

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      lv
      |> element("#sessions-page-next")
      |> render_click()

      assert_patch(lv, ~p"/users/sessions?page=2")

      session_ids = session_ids_for_user(user)
      only_page_2_session_id = Enum.at(session_ids, 10)

      assert {:ok, _revoked} =
               Accounts.revoke_user_session(user_scope_fixture(user), only_page_2_session_id)

      _ = :sys.get_state(lv.pid)
      assert_patch(lv, ~p"/users/sessions")
      assert has_element?(lv, "#sessions-page-label", "Page 1 of 1")
      refute has_element?(lv, "#session-#{only_page_2_session_id}")
    end

    test "toggle expired updates paginated counts", %{conn: conn} do
      user = user_fixture()

      for _ <- 1..9 do
        Accounts.generate_user_session_token(user)
      end

      expired_ids =
        for _ <- 1..4 do
          token = Accounts.generate_user_session_token(user)
          offset_user_token(token, -20, :day)
          Repo.get_by!(UserToken, token: token).id
        end

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      scope = user_scope_fixture(user)
      active_total = Accounts.count_user_sessions(scope, include_expired: false)
      all_total = Accounts.count_user_sessions(scope)

      assert has_element?(lv, "#sessions-total-count", "#{active_total} total sessions")
      assert has_element?(lv, "#sessions-page-label", "Page 1 of 1")

      lv
      |> element("#sessions-toggle-expired")
      |> render_click()

      assert has_element?(lv, "#sessions-toggle-expired", "Hide expired")
      assert has_element?(lv, "#sessions-total-count", "#{all_total} total sessions")
      assert has_element?(lv, "#sessions-page-label", "Page 1 of 2")

      lv
      |> element("#sessions-page-next")
      |> render_click()

      assert_patch(lv, ~p"/users/sessions?page=2")
      assert has_element?(lv, "#session-expired-#{hd(expired_ids)}")
    end

    test "updates list in realtime when a new session is created", %{conn: conn} do
      user = user_fixture()

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      token = Accounts.generate_user_session_token(user)
      %UserToken{id: session_id} = Repo.get_by!(UserToken, token: token)

      _ = :sys.get_state(lv.pid)
      assert has_element?(lv, "#session-#{session_id}")
    end

    test "updates list in realtime when a session is revoked externally", %{conn: conn} do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %UserToken{id: session_id} = Repo.get_by!(UserToken, token: token)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      assert has_element?(lv, "#session-#{session_id}")
      assert {:ok, _revoked} = Accounts.revoke_user_session(user_scope_fixture(user), session_id)

      _ = :sys.get_state(lv.pid)
      refute has_element?(lv, "#session-#{session_id}")
    end

    test "closes revoke modal when targeted session is removed externally", %{conn: conn} do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %UserToken{id: session_id} = Repo.get_by!(UserToken, token: token)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      lv
      |> element("#session-revoke-#{session_id}")
      |> render_click()

      assert_patch(lv, ~p"/users/sessions/#{session_id}/revoke")
      assert has_element?(lv, "#revoke-session-modal")

      assert {:ok, _revoked} = Accounts.revoke_user_session(user_scope_fixture(user), session_id)

      _ = :sys.get_state(lv.pid)
      assert_patch(lv, ~p"/users/sessions")
      refute has_element?(lv, "#revoke-session-modal")
    end

    test "revoke route works for a session not on the current paginated page", %{conn: conn} do
      user = user_fixture()

      for _ <- 1..11 do
        Accounts.generate_user_session_token(user)
      end

      off_page_session_id =
        user
        |> session_ids_for_user()
        |> Enum.at(10)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions/#{off_page_session_id}/revoke")

      assert has_element?(lv, "#revoke-session-modal")
    end

    test "revokes a non-current session with REVOKE confirmation", %{conn: conn} do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %UserToken{id: session_id} = Repo.get_by!(UserToken, token: token)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      lv
      |> element("#session-revoke-#{session_id}")
      |> render_click()

      assert_patch(lv, ~p"/users/sessions/#{session_id}/revoke")
      assert has_element?(lv, "#revoke-session-modal")

      lv
      |> form("#revoke-session-form", %{"revoke" => %{"confirmation" => "REVOKE"}})
      |> render_submit()

      assert_patch(lv, ~p"/users/sessions")
      refute has_element?(lv, "#session-#{session_id}")
      refute Repo.get(UserToken, session_id)
    end

    test "revoking current session redirects to login", %{conn: conn} do
      user = user_fixture()

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      current_session =
        Repo.one!(
          from(t in UserToken,
            where: t.user_id == ^user.id and t.context == "session",
            order_by: [desc: t.inserted_at],
            limit: 1
          )
        )

      lv
      |> element("#session-revoke-#{current_session.id}")
      |> render_click()

      assert_patch(lv, ~p"/users/sessions/#{current_session.id}/revoke")

      assert {:error, {:redirect, %{to: path}}} =
               lv
               |> form("#revoke-session-form", %{"revoke" => %{"confirmation" => "REVOKE"}})
               |> render_submit()

      assert path == ~p"/users/log-in"
    end

    test "shows validation error when revoke confirmation text is incorrect", %{conn: conn} do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %UserToken{id: session_id} = Repo.get_by!(UserToken, token: token)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      lv
      |> element("#session-revoke-#{session_id}")
      |> render_click()

      assert_patch(lv, ~p"/users/sessions/#{session_id}/revoke")

      lv
      |> form("#revoke-session-form", %{"revoke" => %{"confirmation" => "NOPE"}})
      |> render_submit()

      assert has_element?(lv, "#session-#{session_id}")
      assert has_element?(lv, "#revoke-session-form .text-error", "must be REVOKE")
      assert Repo.get(UserToken, session_id)
    end

    test "revoke submit button is disabled until confirmation is valid", %{conn: conn} do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %UserToken{id: session_id} = Repo.get_by!(UserToken, token: token)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/sessions")

      lv
      |> element("#session-revoke-#{session_id}")
      |> render_click()

      assert has_element?(lv, "#revoke-session-confirm[disabled]")

      lv
      |> form("#revoke-session-form", %{"revoke" => %{"confirmation" => "REVOKE"}})
      |> render_change()

      refute has_element?(lv, "#revoke-session-confirm[disabled]")
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/sessions")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "revoke route redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/sessions/123/revoke")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  defp session_ids_for_user(user) do
    Repo.all(
      from(t in UserToken,
        where: t.user_id == ^user.id and t.context == "session",
        order_by: [desc: t.inserted_at, desc: t.id],
        select: t.id
      )
    )
  end
end
