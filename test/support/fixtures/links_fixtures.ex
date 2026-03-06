defmodule Caracol.LinksFixtures do
  @moduledoc """
  This module defines test helpers for links.
  """

  alias Caracol.Accounts.Scope
  alias Caracol.Links

  def valid_link_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      color: "#2563EB",
      description: "A useful reference link.",
      icon: "hero-link",
      name: "Example Link #{System.unique_integer()}",
      url: "https://example.com/#{System.unique_integer([:positive])}"
    })
  end

  def link_fixture(%Scope{} = scope, attrs \\ %{}) do
    {:ok, link} =
      scope
      |> Links.create_link(valid_link_attributes(attrs))

    link
  end
end
