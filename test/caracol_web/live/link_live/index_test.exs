defmodule CaracolWeb.LinkLive.IndexTest do
  use CaracolWeb.ConnCase, async: true

  import Caracol.AccountsFixtures
  import Caracol.LinksFixtures
  import Phoenix.LiveViewTest

  alias Caracol.Accounts.Scope
  alias Caracol.Links

  describe "/links authentication" do
    test "redirects unauthenticated users", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/links")
      assert {:redirect, %{to: path}} = redirect
      assert path == ~p"/users/log-in"
    end
  end

  describe "links management" do
    setup :register_and_log_in_user

    test "shows only current user's links", %{conn: conn, user: user} do
      scope = Scope.for_user(user)
      own_link = link_fixture(scope, %{name: "My Link"})
      _other_link = link_fixture(user_scope_fixture(), %{name: "Other Link"})

      {:ok, view, _html} = live(conn, ~p"/links")

      assert has_element?(view, "#link-#{own_link.id}")
      refute render(view) =~ "Other Link"
    end

    test "creates and edits links through modal routes", %{conn: conn, user: user} do
      scope = Scope.for_user(user)
      {:ok, view, _html} = live(conn, ~p"/links")

      render_click(element(view, "#links-new-button"))
      assert_patch(view, ~p"/links/new")
      assert has_element?(view, "#link-form-modal")
      assert render(view) =~ "phx-submit-loading:btn-disabled"

      link_params = %{
        "name" => "Phoenix Docs",
        "url" => "https://hexdocs.pm/phoenix/overview.html",
        "color" => "#3366FF",
        "description" => ""
      }

      render_click(element(view, "#link-icon-option-hero-bookmark"))

      view
      |> form("#link-form", link: link_params)
      |> render_submit()

      assert_patch(view, ~p"/links")
      [link] = Links.list_links(scope, include_archived: true)
      assert has_element?(view, "#link-#{link.id}")

      render_click(element(view, "#link-edit-#{link.id}"))
      assert_patch(view, ~p"/links/#{link.id}/edit")
      render_click(element(view, "#link-icon-option-hero-bookmark"))

      view
      |> form("#link-form", link: Map.put(link_params, "name", "Phoenix Overview"))
      |> render_submit()

      assert_patch(view, ~p"/links")
      assert render(view) =~ "Phoenix Overview"
    end

    test "archives, restores, and deletes archived links", %{conn: conn, user: user} do
      scope = Scope.for_user(user)
      link = link_fixture(scope, %{name: "Archive Me"})
      restored = link_fixture(scope, %{name: "Restore Me"})

      {:ok, view, _html} = live(conn, ~p"/links")

      render_click(element(view, "#link-archive-#{link.id}"))
      assert has_element?(view, "#link-archived-badge-#{link.id}")

      render_click(element(view, "#link-delete-#{link.id}"))
      assert_patch(view, ~p"/links/#{link.id}/delete")
      render_click(element(view, "#link-delete-confirm"))
      assert_patch(view, ~p"/links")
      refute has_element?(view, "#link-#{link.id}")

      render_click(element(view, "#link-archive-#{restored.id}"))
      render_click(element(view, "#link-unarchive-#{restored.id}"))
      refute has_element?(view, "#link-archived-badge-#{restored.id}")
    end

    test "renders stacked toasts with semantics and dismiss behavior", %{conn: conn, user: user} do
      scope = Scope.for_user(user)

      [first, second, third, fourth] =
        Enum.map(1..4, fn index ->
          link_fixture(scope, %{name: "Favorite #{index}"})
        end)

      {:ok, view, _html} = live(conn, ~p"/links")

      render_click(element(view, "#link-toggle-favorite-#{first.id}"))

      assert has_element?(view, "#flash-group.toast.toast-end.toast-bottom")
      assert has_element?(view, "#flash-group > #flash-info[role='status'][aria-live='polite']")

      assert has_element?(
               view,
               "#flash-group > #flash-info[phx-hook='FlashAutoDismiss'][data-auto-dismiss-ms='5000']"
             )

      refute has_element?(view, "#flash-group > #flash-info[phx-click]")

      assert has_element?(
               view,
               "#flash-group > #flash-info button[data-role='toast-close'][phx-click]"
             )

      assert has_element?(
               view,
               "#flash-group > #flash-info button[data-role='toast-close'][class*='h-11'][class*='w-11'][class*='focus-visible:outline']"
             )

      render_click(element(view, "#link-toggle-favorite-#{second.id}"))
      render_click(element(view, "#link-toggle-favorite-#{third.id}"))
      render_click(element(view, "#link-toggle-favorite-#{fourth.id}"))

      assert has_element?(view, "#flash-group > #flash-info")

      assert has_element?(
               view,
               "#flash-group > #flash-error[role='alert'][aria-live='assertive']"
             )

      refute has_element?(view, "#flash-group > #flash-error[phx-hook='FlashAutoDismiss']")

      assert has_element?(
               view,
               "#flash-group > #flash-error button[data-role='toast-close'][phx-click]"
             )
    end

    test "updates click count in real time when a link is opened", %{conn: conn, user: user} do
      scope = Scope.for_user(user)
      link = link_fixture(scope, %{name: "Open Me"})

      {:ok, view, _html} = live(conn, ~p"/links")
      assert has_element?(view, "#link-click-count-#{link.id}", "Clicks: 0")

      assert {:ok, _opened_link} = Links.open_link(scope, link.id)
      _ = :sys.get_state(view.pid)

      assert has_element?(view, "#link-click-count-#{link.id}", "Clicks: 1")
    end
  end

  describe "global favorites in sidebar" do
    test "updates in real time across users", %{conn: conn} do
      user_one = user_fixture()
      user_two = user_fixture()
      scope_one = Scope.for_user(user_one)
      scope_two = Scope.for_user(user_two)

      link_one = link_fixture(scope_one, %{name: "Global Favorite 1"})
      link_two = link_fixture(scope_two, %{name: "Global Favorite 2"})

      {:ok, view_one, _html} =
        conn
        |> log_in_user(user_one)
        |> live(~p"/home")

      {:ok, view_two, _html} =
        build_conn()
        |> log_in_user(user_two)
        |> live(~p"/home")

      refute has_element?(view_one, "#app-sidebar-favorite-links")
      refute has_element?(view_two, "#app-sidebar-favorite-links")

      assert {:ok, _} = Links.toggle_favorite(scope_one, link_one.id)
      assert {:ok, _} = Links.toggle_favorite(scope_two, link_two.id)

      assert has_element?(view_one, "#app-sidebar-favorite-link-#{link_one.id}")
      assert has_element?(view_one, "#app-sidebar-favorite-link-#{link_two.id}")
      assert has_element?(view_two, "#app-sidebar-favorite-link-#{link_one.id}")
      assert has_element?(view_two, "#app-sidebar-favorite-link-#{link_two.id}")
    end
  end
end
