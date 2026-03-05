defmodule CaracolWeb.UserRedirectController do
  use CaracolWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: ~p"/users/settings")
  end
end
