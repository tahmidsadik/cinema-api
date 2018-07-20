defmodule CinemaApiWeb.CineApiController do
  import CinemaApi.DataProvider, only: [get_cineplex_movies_with_omdb_data: 0]
  import CinemaApi.DataPersistence, only: [persist_movies: 1]
  import CinemaApi.Movies, only: [get_movies: 0]
  use CinemaApiWeb, :controller

  def index(conn, _params) do
    movies = get_cineplex_movies_with_omdb_data()
    persist_movies(movies)
    json(conn, movies)
    # case get_movies_with_imdb_info() do
    #   {:ok, movies} -> json(conn, %{movies: movies})
    #   {:err, msg} -> json(conn, %{err: msg})
    # end
  end

  def provide_cineplex_movies(conn, _params) do
    movies = get_movies()
    json(conn, movies)
  end
end
