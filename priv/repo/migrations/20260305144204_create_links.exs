defmodule Caracol.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :url, :string, null: false
      add :icon, :string, null: false
      add :color, :string, null: false
      add :description, :text
      add :is_favorite, :boolean, default: false, null: false
      add :click_count, :integer, default: 0, null: false
      add :archived_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:links, [:user_id])
    create index(:links, [:user_id, :archived_at])
    create index(:links, [:is_favorite, :archived_at, :name])
    create unique_index(:links, [:user_id, :url])

    create constraint(:links, :links_click_count_non_negative, check: "click_count >= 0")
  end
end
