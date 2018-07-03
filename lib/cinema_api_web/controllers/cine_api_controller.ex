defmodule CinemaApiWeb.CineApiController do
  import CinemaApi.CinemaInfoFetcher, only: [get_cineplex_movies_with_omdb_data: 0]
  use CinemaApiWeb, :controller

  def index(conn, _params) do
    json(conn, get_cineplex_movies_with_omdb_data)
    # case get_movies_with_imdb_info() do
    #   {:ok, movies} -> json(conn, %{movies: movies})
    #   {:err, msg} -> json(conn, %{err: msg})
    # end
  end
end
