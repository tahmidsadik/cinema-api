defmodule CinemaApi.Movies do
  @moduledoc """
  provides functions for getting currently showing movies and showtimes from db
  """
  alias CinemaApi.Schemas.Movie
  alias CinemaApi.Schemas.Showtime
  alias CinemaApi.Repo
  import Ecto.Query
  import Enum, only: [map: 2, zip: 2, filter: 2]
  import Map, only: [from_struct: 1, delete: 2]

  def get_movies() do
    movies = Repo.all(from(m in Movie, preload: [:showtimes]))

    movies
    |> map(fn mov -> mov |> from_struct() end)
    |> map(fn mov ->
      mov.showtimes
      |> map(fn st -> st |> from_struct end)
      |> map(fn st -> st |> delete(:__meta__) end)
    end)

    # movies = Repo.all(Movie)
    # showtimes =
    #   movies
    #   |> filter(fn mov -> mov.imdb_id != nil end)
    #   |> map(fn mov ->
    #     from(
    #       s in Showtime,
    #       where: s.movie_id == ^mov.id,
    #       select: %{id: s.id,  }
    #     )
    #   end)
    #   |> map(fn query -> Repo.all(query) end)
    #   |> map(fn showtime_list -> map(showtime_list, fn s -> s.showtime end) end)
    #
    # zip(movies, showtimes)
    # |> map(fn movie -> Map.put(elem(movie, 0), :schedules, elem(movie, 1)) end)
    # |> map(fn mov ->
    #   {_, y} = Map.from_struct(mov) |> Map.pop(:__meta__)
    #   y
    # end)
  end
end
