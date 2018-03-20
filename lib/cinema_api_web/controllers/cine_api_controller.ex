defmodule CinemaApiWeb.CineApiController do
  import CinemaApi.CinemaInfoFetcher, only: [get_cineplex_movie_list: 0]
  use CinemaApiWeb, :controller

  def index(conn, _params) do
    case get_cineplex_movie_list() do
      {:ok, movies} -> json(conn, %{movies: movies})
      {:err, msg} -> json(conn, %{err: msg})
    end
  end
end
