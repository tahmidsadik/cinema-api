defmodule CinemaApiWeb.Router do
  use CinemaApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"] end

  scope "/", CinemaApiWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/hello", HelloController, :index
    get "/hello/:messenger", HelloController, :show
  end

  scope "/api", CinemaApiWeb do
    pipe_through :api # User the default api stack

    get "/", CineApiController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CinemaApiWeb do
  #   pipe_through :api
  # end
end
