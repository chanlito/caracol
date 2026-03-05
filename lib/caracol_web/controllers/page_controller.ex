defmodule CaracolWeb.PageController do
  use CaracolWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
