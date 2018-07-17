defmodule CinemaApiWeb.Router do
  use CinemaApiWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", CinemaApiWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/hello", HelloController, :index)
    get("/hello/:messenger", HelloController, :show)
  end

  scope "/api", CinemaApiWeb do
    # User the default api stack
    pipe_through(:api)

    get("/fetch", CineApiController, :index)
    get("/movies/cineplex", CineApiController, :provide_cineplex_movies)
  end

  # Other scopes may use custom stacks.
  # scope "/api", CinemaApiWeb do
  #   pipe_through :api
  # end
end
