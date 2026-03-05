defmodule CaracolWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use CaracolWeb, :html
  import CaracolWeb.ThemeComponents, only: [theme_dropdown: 1]

  embed_templates "page_html/*"
end
