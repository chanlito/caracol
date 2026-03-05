defmodule Caracol.Repo.Migrations.AddSessionMetadataToUserTokens do
  use Ecto.Migration

  def change do
    alter table(:users_tokens) do
      add :user_agent, :string
      add :ip_address, :string
    end
  end
end
