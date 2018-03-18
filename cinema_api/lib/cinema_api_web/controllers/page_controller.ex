defmodule CinemaApiWeb.PageController do
  use CinemaApiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
