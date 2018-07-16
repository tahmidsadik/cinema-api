defmodule CinemaApiWeb.CineApiController do
  import CinemaApi.DataProvider, only: [get_cineplex_movies_with_omdb_data: 0]
  import CinemaApi.DataPersistence
  use CinemaApiWeb, :controller

  def index(conn, _params) do
    movies = get_cineplex_movies_with_omdb_data()
    save_fetched_movies(movies)
    save_showtimes(movies)
    json(conn, movies)
    # case get_movies_with_imdb_info() do
    #   {:ok, movies} -> json(conn, %{movies: movies})
    #   {:err, msg} -> json(conn, %{err: msg})
    # end
  end
end
