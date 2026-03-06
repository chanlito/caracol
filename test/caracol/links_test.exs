defmodule Caracol.LinksTest do
  use Caracol.DataCase, async: true

  import Caracol.AccountsFixtures
  import Caracol.LinksFixtures

  alias Caracol.Links

  describe "links" do
    test "list_links/2 returns only links owned by the scoped user" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      own_link = link_fixture(scope)
      _other_link = link_fixture(other_scope)

      assert [listed_link] = Links.list_links(scope, include_archived: true)
      assert listed_link.id == own_link.id
    end

    test "create_link/2 validates optional description and url format" do
      scope = user_scope_fixture()

      {:ok, link} =
        Links.create_link(scope, %{
          name: "Phoenix",
          url: "https://phoenixframework.org",
          icon: "hero-link",
          color: "#123ABC",
          description: nil
        })

      assert is_nil(link.description)

      assert {:error, changeset} =
               Links.create_link(scope, %{
                 name: "Broken",
                 url: "notaurl",
                 icon: "hero-link",
                 color: "#123ABC"
               })

      assert "must be a valid http/https URL" in errors_on(changeset).url
    end

    test "create_link/2 enforces description max length of 500" do
      scope = user_scope_fixture()
      too_long_description = String.duplicate("a", 501)

      assert {:error, changeset} =
               Links.create_link(scope, %{
                 name: "Long",
                 url: "https://example.com/long",
                 icon: "hero-link",
                 color: "#123ABC",
                 description: too_long_description
               })

      assert "should be at most 500 character(s)" in errors_on(changeset).description
    end

    test "toggle_favorite/2 enforces favorite limit of three" do
      scope = user_scope_fixture()
      [one, two, three, four] = Enum.map(1..4, fn _ -> link_fixture(scope) end)

      assert {:ok, %{is_favorite: true}} = Links.toggle_favorite(scope, one.id)
      assert {:ok, %{is_favorite: true}} = Links.toggle_favorite(scope, two.id)
      assert {:ok, %{is_favorite: true}} = Links.toggle_favorite(scope, three.id)
      assert {:error, :favorite_limit_reached} = Links.toggle_favorite(scope, four.id)
    end

    test "toggle_favorite/2 only allows owners to favorite their own links" do
      owner_scope = user_scope_fixture()
      non_owner_scope = user_scope_fixture()
      link = link_fixture(owner_scope)

      assert {:error, :not_found} = Links.toggle_favorite(non_owner_scope, link.id)
    end

    test "list_global_favorite_links/0 returns active favorites sorted by name" do
      scope = user_scope_fixture()
      zebra = link_fixture(scope, %{name: "Zebra"})
      alpha = link_fixture(scope, %{name: "Alpha"})

      assert {:ok, _} = Links.toggle_favorite(scope, zebra.id)
      assert {:ok, _} = Links.toggle_favorite(scope, alpha.id)
      assert {:ok, _} = Links.archive_link(scope, zebra.id)

      favorite_names =
        Links.list_global_favorite_links()
        |> Enum.map(& &1.name)

      assert favorite_names == ["Alpha"]
    end

    test "delete_archived_link/2 requires archived state" do
      scope = user_scope_fixture()
      link = link_fixture(scope)

      assert {:error, :not_archived} = Links.delete_archived_link(scope, link.id)
      assert {:ok, _link} = Links.archive_link(scope, link.id)
      assert {:ok, _deleted_link} = Links.delete_archived_link(scope, link.id)
      assert [] = Links.list_links(scope, include_archived: true)
    end

    test "open_link/2 increments click count for active links" do
      scope = user_scope_fixture()
      link = link_fixture(scope)

      assert {:ok, opened_link} = Links.open_link(scope, link.id)
      assert opened_link.click_count == 1

      assert {:ok, _archived_link} = Links.archive_link(scope, link.id)
      assert {:error, :not_found} = Links.open_link(scope, link.id)
    end
  end
end
