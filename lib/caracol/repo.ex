defmodule Caracol.Repo do
  use Ecto.Repo,
    otp_app: :caracol,
    adapter: Ecto.Adapters.Postgres
end
