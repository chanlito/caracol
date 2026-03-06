defmodule Caracol.Links.Link do
  use Ecto.Schema
  import Ecto.Changeset

  alias Caracol.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @icon_options [
    "hero-link",
    "hero-globe-alt",
    "hero-bookmark",
    "hero-folder",
    "hero-document-text",
    "hero-code-bracket",
    "hero-light-bulb",
    "hero-academic-cap",
    "hero-briefcase",
    "hero-chart-bar"
  ]

  schema "links" do
    field :name, :string
    field :url, :string
    field :icon, :string
    field :color, :string
    field :description, :string
    field :is_favorite, :boolean, default: false
    field :click_count, :integer, default: 0
    field :archived_at, :utc_datetime

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def icon_options, do: @icon_options

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:name, :url, :icon, :color, :description])
    |> update_change(:name, &String.trim/1)
    |> update_change(:url, &String.trim/1)
    |> update_change(:description, &normalize_description/1)
    |> validate_required([:name, :url, :icon, :color])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:description, max: 500)
    |> validate_inclusion(:icon, @icon_options)
    |> validate_format(:color, ~r/^#[0-9A-Fa-f]{6}$/, message: "must be a valid hex color")
    |> validate_http_url()
    |> unique_constraint(:url, name: :links_user_id_url_index)
  end

  defp normalize_description(value) when is_binary(value) do
    value
    |> String.trim()
    |> case do
      "" -> nil
      description -> description
    end
  end

  defp normalize_description(value), do: value

  defp validate_http_url(changeset) do
    validate_change(changeset, :url, fn :url, value ->
      uri = URI.parse(value)

      if uri.scheme in ["http", "https"] and is_binary(uri.host) and uri.host != "" do
        []
      else
        [url: "must be a valid http/https URL"]
      end
    end)
  end
end
