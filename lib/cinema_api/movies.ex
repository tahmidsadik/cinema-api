defmodule CinemaApi.Movies do
  @moduledoc """
  provides functions for getting currently showing movies and showtimes from db
  """
  alias CinemaApi.Schemas.Movie
  alias CinemaApi.Schemas.Showtime
  alias CinemaApi.Repo
  import Ecto.Query
  import Enum, only: [map: 2, zip: 2]

  def get_movies() do
    movies = Repo.all(Movie)

    showtimes =
      movies
      |> map(fn mov ->
        from(
          s in Showtime,
          where: s.imdb_id == ^mov.imdb_id,
          select: s
        )
      end)
      |> map(fn query -> Repo.all(query) end)
      |> map(fn showtime_list -> map(showtime_list, fn s -> s.showtime end) end)

    zip(movies, showtimes)
    |> map(fn movie -> Map.put(elem(movie, 0), :schedules, elem(movie, 1)) end)
    |> map(fn mov ->
      {_, y} = Map.from_struct(mov) |> Map.pop(:__meta__)
      y
    end)
  end
end
