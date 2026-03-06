defmodule CaracolWeb.Router do
  use CaracolWeb, :router

  import CaracolWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CaracolWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CaracolWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", CaracolWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:caracol, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CaracolWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CaracolWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users", UserRedirectController, :index
    get "/links/:id/open", LinkRedirectController, :open

    live_session :require_authenticated_user,
      on_mount: [
        {CaracolWeb.UserAuth, :require_authenticated},
        {CaracolWeb.GlobalFavorites, :global_favorites}
      ] do
      live "/home", AppLive.Home, :index
      live "/playground", AppLive.Playground, :index
      live "/links", LinkLive.Index, :index
      live "/links/new", LinkLive.Index, :new
      live "/links/:id/edit", LinkLive.Index, :edit
      live "/links/:id/delete", LinkLive.Index, :delete
      live "/users/settings", UserLive.Settings, :edit
      live "/users/appearance", UserLive.Appearance, :index
      live "/users/sessions", UserLive.Sessions, :index
      live "/users/sessions/:id/revoke", UserLive.Sessions, :revoke
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", CaracolWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{CaracolWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
